from rest_framework import status, permissions
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.db import transaction
from django.shortcuts import get_object_or_404
from django.db.models import Q, Sum, Avg, Count, Min, Max
from django.utils import timezone
from datetime import timedelta, date
from decimal import Decimal
from .models import Labor
from .serializers import (
    LaborBulkActionSerializer,
    LaborSerializer,
    LaborCreateSerializer,
    LaborListSerializer,
    LaborStatsSerializer,
    LaborUpdateSerializer,
    LaborDetailSerializer,
    LaborContactUpdateSerializer,
    LaborSalaryUpdateSerializer,
)
from .signals import labor_bulk_updated


# ==================== BASIC CRUD OPERATIONS ====================

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def list_labors(request):
    """
    List all active labors with pagination, search, and filtering
    """
    try:
        # Get query parameters
        show_inactive = request.GET.get('show_inactive', 'false').lower() == 'true'
        page_size = min(int(request.GET.get('page_size', 20)), 100)
        page = int(request.GET.get('page', 1))
        
        # Search parameters
        search = request.GET.get('search', '').strip()
        city = request.GET.get('city', '').strip()
        area = request.GET.get('area', '').strip()
        designation = request.GET.get('designation', '').strip()
        caste = request.GET.get('caste', '').strip()
        gender = request.GET.get('gender', '').strip()
        
        # Salary range filters
        min_salary = request.GET.get('min_salary', '').strip()
        max_salary = request.GET.get('max_salary', '').strip()
        
        # Age range filters
        min_age = request.GET.get('min_age', '').strip()
        max_age = request.GET.get('max_age', '').strip()
        
        # Date range filters
        joined_after = request.GET.get('joined_after', '').strip()
        joined_before = request.GET.get('joined_before', '').strip()
        
        # Sorting
        sort_by = request.GET.get('sort_by', 'name')  # name, joining_date, salary, age
        sort_order = request.GET.get('sort_order', 'asc')  # asc, desc
        
        # Base queryset
        if show_inactive:
            labors = Labor.objects.all()
        else:
            labors = Labor.active_labors()
        
        # Apply search filter
        if search:
            labors = labors.search(search)
        
        # Apply filters
        if city:
            labors = labors.filter(city__iexact=city)
        
        if area:
            labors = labors.filter(area__iexact=area)
        
        if designation:
            labors = labors.filter(designation__iexact=designation)
        
        if caste:
            labors = labors.filter(caste__iexact=caste)
        
        if gender:
            labors = labors.filter(gender=gender)
        
        # Apply salary range filters
        if min_salary:
            try:
                labors = labors.filter(salary__gte=Decimal(min_salary))
            except (ValueError, TypeError):
                return Response({
                    'success': False,
                    'message': 'Invalid min_salary value.',
                    'errors': {'min_salary': 'Must be a valid number'}
                }, status=status.HTTP_400_BAD_REQUEST)
        
        if max_salary:
            try:
                labors = labors.filter(salary__lte=Decimal(max_salary))
            except (ValueError, TypeError):
                return Response({
                    'success': False,
                    'message': 'Invalid max_salary value.',
                    'errors': {'max_salary': 'Must be a valid number'}
                }, status=status.HTTP_400_BAD_REQUEST)
        
        # Apply age range filters
        if min_age:
            try:
                labors = labors.filter(age__gte=int(min_age))
            except (ValueError, TypeError):
                return Response({
                    'success': False,
                    'message': 'Invalid min_age value.',
                    'errors': {'min_age': 'Must be a valid integer'}
                }, status=status.HTTP_400_BAD_REQUEST)
        
        if max_age:
            try:
                labors = labors.filter(age__lte=int(max_age))
            except (ValueError, TypeError):
                return Response({
                    'success': False,
                    'message': 'Invalid max_age value.',
                    'errors': {'max_age': 'Must be a valid integer'}
                }, status=status.HTTP_400_BAD_REQUEST)
        
        # Apply date range filters
        if joined_after:
            try:
                labors = labors.filter(joining_date__gte=joined_after)
            except ValueError:
                return Response({
                    'success': False,
                    'message': 'Invalid joined_after date format. Use YYYY-MM-DD.',
                    'errors': {'joined_after': 'Invalid date format'}
                }, status=status.HTTP_400_BAD_REQUEST)
        
        if joined_before:
            try:
                labors = labors.filter(joining_date__lte=joined_before)
            except ValueError:
                return Response({
                    'success': False,
                    'message': 'Invalid joined_before date format. Use YYYY-MM-DD.',
                    'errors': {'joined_before': 'Invalid date format'}
                }, status=status.HTTP_400_BAD_REQUEST)
        
        # Apply sorting
        sort_fields = {
            'name': 'name',
            'joining_date': 'joining_date',
            'salary': 'salary',
            'age': 'age',
            'designation': 'designation',
            'caste': 'caste',
            'city': 'city',
            'area': 'area',
            'created_at': 'created_at',
            'updated_at': 'updated_at'
        }
        
        if sort_by in sort_fields:
            order_field = sort_fields[sort_by]
            if sort_order == 'desc':
                order_field = f'-{order_field}'
            labors = labors.order_by(order_field)
        
        # Select related to avoid N+1 queries
        labors = labors.select_related('created_by')
        
        # Calculate pagination
        total_count = labors.count()
        start_index = (page - 1) * page_size
        end_index = start_index + page_size
        
        labors = labors[start_index:end_index]
        
        serializer = LaborListSerializer(labors, many=True)
        
        return Response({
            'success': True,
            'data': {
                'labors': serializer.data,
                'pagination': {
                    'current_page': page,
                    'page_size': page_size,
                    'total_count': total_count,
                    'total_pages': (total_count + page_size - 1) // page_size,
                    'has_next': end_index < total_count,
                    'has_previous': page > 1
                },
                'filters_applied': {
                    'search': search,
                    'city': city,
                    'area': area,
                    'designation': designation,
                    'caste': caste,
                    'gender': gender,
                    'min_salary': min_salary,
                    'max_salary': max_salary,
                    'min_age': min_age,
                    'max_age': max_age,
                    'joined_after': joined_after,
                    'joined_before': joined_before,
                    'sort_by': sort_by,
                    'sort_order': sort_order
                }
            }
        }, status=status.HTTP_200_OK)
        
    except ValueError as e:
        return Response({
            'success': False,
            'message': 'Invalid pagination parameters.',
            'errors': {'detail': str(e)}
        }, status=status.HTTP_400_BAD_REQUEST)
    
    except Exception as e:
        return Response({
            'success': False,
            'message': 'Failed to retrieve labors.',
            'errors': {'detail': str(e)}
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def create_labor(request):
    """
    Create a new labor
    """
    serializer = LaborCreateSerializer(
        data=request.data,
        context={'request': request}
    )
    
    if serializer.is_valid():
        try:
            with transaction.atomic():
                labor = serializer.save()
                
                return Response({
                    'success': True,
                    'message': 'Labor created successfully.',
                    'data': LaborDetailSerializer(labor).data
                }, status=status.HTTP_201_CREATED)
                
        except Exception as e:
            return Response({
                'success': False,
                'message': 'Labor creation failed due to server error.',
                'errors': {'detail': str(e)}
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    
    return Response({
        'success': False,
        'message': 'Labor creation failed.',
        'errors': serializer.errors
    }, status=status.HTTP_400_BAD_REQUEST)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_labor(request, labor_id):
    """
    Retrieve a specific labor by ID
    """
    try:
        labor = get_object_or_404(Labor, id=labor_id)
        serializer = LaborDetailSerializer(labor)
        
        return Response({
            'success': True,
            'data': serializer.data
        }, status=status.HTTP_200_OK)
        
    except Exception as e:
        return Response({
            'success': False,
            'message': 'Labor not found.',
            'errors': {'detail': str(e)}
        }, status=status.HTTP_404_NOT_FOUND)


@api_view(['PUT', 'PATCH'])
@permission_classes([IsAuthenticated])
def update_labor(request, labor_id):
    """
    Update a labor
    """
    try:
        labor = get_object_or_404(Labor, id=labor_id)
        
        serializer = LaborUpdateSerializer(
            labor,
            data=request.data,
            partial=request.method == 'PATCH'
        )
        
        if serializer.is_valid():
            try:
                with transaction.atomic():
                    labor = serializer.save()
                    
                    return Response({
                        'success': True,
                        'message': 'Labor updated successfully.',
                        'data': LaborDetailSerializer(labor).data
                    }, status=status.HTTP_200_OK)
                    
            except Exception as e:
                return Response({
                    'success': False,
                    'message': 'Labor update failed due to server error.',
                    'errors': {'detail': str(e)}
                }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
        
        return Response({
            'success': False,
            'message': 'Labor update failed.',
            'errors': serializer.errors
        }, status=status.HTTP_400_BAD_REQUEST)
        
    except Labor.DoesNotExist:
        return Response({
            'success': False,
            'message': 'Labor not found.',
            'errors': {'detail': 'Labor with this ID does not exist.'}
        }, status=status.HTTP_404_NOT_FOUND)


@api_view(['DELETE'])
@permission_classes([IsAuthenticated])
def delete_labor(request, labor_id):
    """
    Hard delete a labor (permanently remove from database)
    """
    try:
        labor = get_object_or_404(Labor, id=labor_id)
        
        # Store labor name for response message
        labor_name = labor.name
        
        # Check if labor has payments (optional safety check)
        # Uncomment this if you have a Payment model that references labors
        # if hasattr(labor, 'payments') and labor.payments.exists():
        #     return Response({
        #         'success': False,
        #         'message': 'Cannot delete labor as they have existing payments.',
        #         'errors': {'detail': 'This labor has payment history.'}
        #     }, status=status.HTTP_400_BAD_REQUEST)
        
        # Permanently delete the labor
        labor.delete()
        
        return Response({
            'success': True,
            'message': f'Labor "{labor_name}" deleted permanently.'
        }, status=status.HTTP_200_OK)
        
    except Labor.DoesNotExist:
        return Response({
            'success': False,
            'message': 'Labor not found.',
            'errors': {'detail': 'Labor with this ID does not exist.'}
        }, status=status.HTTP_404_NOT_FOUND)
    
    except Exception as e:
        return Response({
            'success': False,
            'message': 'Labor deletion failed.',
            'errors': {'detail': str(e)}
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def soft_delete_labor(request, labor_id):
    """
    Soft delete a labor (set is_active=False)
    """
    try:
        labor = get_object_or_404(Labor, id=labor_id)
        
        if not labor.is_active:
            return Response({
                'success': False,
                'message': 'Labor is already inactive.',
                'errors': {'detail': 'This labor has already been soft deleted.'}
            }, status=status.HTTP_400_BAD_REQUEST)
        
        labor.soft_delete()
        
        return Response({
            'success': True,
            'message': 'Labor soft deleted successfully.'
        }, status=status.HTTP_200_OK)
        
    except Labor.DoesNotExist:
        return Response({
            'success': False,
            'message': 'Labor not found.',
            'errors': {'detail': 'Labor with this ID does not exist.'}
        }, status=status.HTTP_404_NOT_FOUND)
    
    except Exception as e:
        return Response({
            'success': False,
            'message': 'Labor soft deletion failed.',
            'errors': {'detail': str(e)}
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def restore_labor(request, labor_id):
    """
    Restore a soft-deleted labor (set is_active=True)
    """
    try:
        labor = get_object_or_404(Labor, id=labor_id)
        
        if labor.is_active:
            return Response({
                'success': False,
                'message': 'Labor is already active.',
                'errors': {'detail': 'This labor is not deleted.'}
            }, status=status.HTTP_400_BAD_REQUEST)
        
        labor.restore()
        
        return Response({
            'success': True,
            'message': 'Labor restored successfully.',
            'data': LaborDetailSerializer(labor).data
        }, status=status.HTTP_200_OK)
        
    except Labor.DoesNotExist:
        return Response({
            'success': False,
            'message': 'Labor not found.',
            'errors': {'detail': 'Labor with this ID does not exist.'}
        }, status=status.HTTP_404_NOT_FOUND)
    
    except Exception as e:
        return Response({
            'success': False,
            'message': 'Labor restoration failed.',
            'errors': {'detail': str(e)}
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['PUT'])
@permission_classes([IsAuthenticated])
def update_labor_contact(request, labor_id):
    """
    Update labor contact information
    """
    try:
        labor = get_object_or_404(Labor, id=labor_id)
        
        serializer = LaborContactUpdateSerializer(
            labor,
            data=request.data,
            partial=True
        )
        
        if serializer.is_valid():
            try:
                with transaction.atomic():
                    labor = serializer.save()
                    
                    return Response({
                        'success': True,
                        'message': 'Labor contact information updated successfully.',
                        'data': {
                            'id': str(labor.id),
                            'name': labor.name,
                            'phone_number': labor.phone_number,
                            'city': labor.city,
                            'area': labor.area
                        }
                    }, status=status.HTTP_200_OK)
                    
            except Exception as e:
                return Response({
                    'success': False,
                    'message': 'Contact update failed due to server error.',
                    'errors': {'detail': str(e)}
                }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
        
        return Response({
            'success': False,
            'message': 'Contact update failed.',
            'errors': serializer.errors
        }, status=status.HTTP_400_BAD_REQUEST)
        
    except Labor.DoesNotExist:
        return Response({
            'success': False,
            'message': 'Labor not found.',
            'errors': {'detail': 'Labor with this ID does not exist.'}
        }, status=status.HTTP_404_NOT_FOUND)


@api_view(['PUT'])
@permission_classes([IsAuthenticated])
def update_labor_salary(request, labor_id):
    """
    Update labor salary and designation
    """
    try:
        labor = get_object_or_404(Labor, id=labor_id)
        
        serializer = LaborSalaryUpdateSerializer(
            labor,
            data=request.data,
            partial=True
        )
        
        if serializer.is_valid():
            try:
                with transaction.atomic():
                    old_salary = labor.salary
                    old_designation = labor.designation
                    
                    labor = serializer.save()
                    
                    return Response({
                        'success': True,
                        'message': 'Labor salary/designation updated successfully.',
                        'data': {
                            'id': str(labor.id),
                            'name': labor.name,
                            'designation': labor.designation,
                            'old_designation': old_designation,
                            'salary': str(labor.salary),
                            'old_salary': str(old_salary)
                        }
                    }, status=status.HTTP_200_OK)
                    
            except Exception as e:
                return Response({
                    'success': False,
                    'message': 'Salary/designation update failed due to server error.',
                    'errors': {'detail': str(e)}
                }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
        
        return Response({
            'success': False,
            'message': 'Salary/designation update failed.',
            'errors': serializer.errors
        }, status=status.HTTP_400_BAD_REQUEST)
        
    except Labor.DoesNotExist:
        return Response({
            'success': False,
            'message': 'Labor not found.',
            'errors': {'detail': 'Labor with this ID does not exist.'}
        }, status=status.HTTP_404_NOT_FOUND)


# ==================== FILTERING AND SEARCH OPERATIONS ====================

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def labors_by_city(request, city_name):
    """
    Get labors by city
    """
    try:
        page_size = min(int(request.GET.get('page_size', 20)), 100)
        page = int(request.GET.get('page', 1))
        
        # Get labors by city (case-insensitive)
        labors = Labor.active_labors().filter(city__iexact=city_name)
        labors = labors.select_related('created_by')
        
        # Calculate pagination
        total_count = labors.count()
        start_index = (page - 1) * page_size
        end_index = start_index + page_size
        
        labors = labors[start_index:end_index]
        
        serializer = LaborListSerializer(labors, many=True)
        
        return Response({
            'success': True,
            'data': {
                'labors': serializer.data,
                'pagination': {
                    'current_page': page,
                    'page_size': page_size,
                    'total_count': total_count,
                    'total_pages': (total_count + page_size - 1) // page_size,
                    'has_next': end_index < total_count,
                    'has_previous': page > 1
                },
                'city': city_name,
                'total_labors_in_city': total_count
            }
        }, status=status.HTTP_200_OK)
        
    except ValueError:
        return Response({
            'success': False,
            'message': 'Invalid pagination parameters.',
            'errors': {'detail': 'Page and page_size must be valid integers.'}
        }, status=status.HTTP_400_BAD_REQUEST)
    
    except Exception as e:
        return Response({
            'success': False,
            'message': 'Failed to retrieve labors by city.',
            'errors': {'detail': str(e)}
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def labors_by_area(request, area_name):
    """
    Get labors by area
    """
    try:
        page_size = min(int(request.GET.get('page_size', 20)), 100)
        page = int(request.GET.get('page', 1))
        
        # Get labors by area (case-insensitive)
        labors = Labor.active_labors().filter(area__iexact=area_name)
        labors = labors.select_related('created_by')
        
        # Calculate pagination
        total_count = labors.count()
        start_index = (page - 1) * page_size
        end_index = start_index + page_size
        
        labors = labors[start_index:end_index]
        
        serializer = LaborListSerializer(labors, many=True)
        
        return Response({
            'success': True,
            'data': {
                'labors': serializer.data,
                'pagination': {
                    'current_page': page,
                    'page_size': page_size,
                    'total_count': total_count,
                    'total_pages': (total_count + page_size - 1) // page_size,
                    'has_next': end_index < total_count,
                    'has_previous': page > 1
                },
                'area': area_name,
                'total_labors_in_area': total_count
            }
        }, status=status.HTTP_200_OK)
        
    except ValueError:
        return Response({
            'success': False,
            'message': 'Invalid pagination parameters.',
            'errors': {'detail': 'Page and page_size must be valid integers.'}
        }, status=status.HTTP_400_BAD_REQUEST)
    
    except Exception as e:
        return Response({
            'success': False,
            'message': 'Failed to retrieve labors by area.',
            'errors': {'detail': str(e)}
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def labors_by_designation(request, designation_name):
    """
    Get labors by designation
    """
    try:
        page_size = min(int(request.GET.get('page_size', 20)), 100)
        page = int(request.GET.get('page', 1))
        
        # Get labors by designation (case-insensitive)
        labors = Labor.active_labors().filter(designation__iexact=designation_name)
        labors = labors.select_related('created_by')
        
        # Calculate pagination
        total_count = labors.count()
        start_index = (page - 1) * page_size
        end_index = start_index + page_size
        
        labors = labors[start_index:end_index]
        
        serializer = LaborListSerializer(labors, many=True)
        
        return Response({
            'success': True,
            'data': {
                'labors': serializer.data,
                'pagination': {
                    'current_page': page,
                    'page_size': page_size,
                    'total_count': total_count,
                    'total_pages': (total_count + page_size - 1) // page_size,
                    'has_next': end_index < total_count,
                    'has_previous': page > 1
                },
                'designation': designation_name,
                'total_labors_with_designation': total_count
            }
        }, status=status.HTTP_200_OK)
        
    except ValueError:
        return Response({
            'success': False,
            'message': 'Invalid pagination parameters.',
            'errors': {'detail': 'Page and page_size must be valid integers.'}
        }, status=status.HTTP_400_BAD_REQUEST)
    
    except Exception as e:
        return Response({
            'success': False,
            'message': 'Failed to retrieve labors by designation.',
            'errors': {'detail': str(e)}
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def search_labors(request):
    """
    Search labors by name, cnic, phone, caste, designation, city, or area
    """
    try:
        query = request.GET.get('q', '').strip()
        if not query:
            return Response({
                'success': False,
                'message': 'Search query is required.',
                'errors': {'detail': 'Please provide a search query parameter "q".'}
            }, status=status.HTTP_400_BAD_REQUEST)
        
        page_size = min(int(request.GET.get('page_size', 20)), 100)
        page = int(request.GET.get('page', 1))
        
        # Additional filters
        city = request.GET.get('city', '').strip()
        area = request.GET.get('area', '').strip()
        designation = request.GET.get('designation', '').strip()
        caste = request.GET.get('caste', '').strip()
        gender = request.GET.get('gender', '').strip()
        
        # Search labors
        labors = Labor.active_labors().search(query)
        
        # Apply additional filters
        if city:
            labors = labors.filter(city__iexact=city)
        
        if area:
            labors = labors.filter(area__iexact=area)
        
        if designation:
            labors = labors.filter(designation__iexact=designation)
        
        if caste:
            labors = labors.filter(caste__iexact=caste)
        
        if gender:
            labors = labors.filter(gender=gender)
        
        labors = labors.select_related('created_by')
        
        # Calculate pagination
        total_count = labors.count()
        start_index = (page - 1) * page_size
        end_index = start_index + page_size
        
        labors = labors[start_index:end_index]
        
        serializer = LaborListSerializer(labors, many=True)
        
        return Response({
            'success': True,
            'data': {
                'labors': serializer.data,
                'pagination': {
                    'current_page': page,
                    'page_size': page_size,
                    'total_count': total_count,
                    'total_pages': (total_count + page_size - 1) // page_size,
                    'has_next': end_index < total_count,
                    'has_previous': page > 1
                },
                'search_query': query,
                'filters_applied': {
                    'city': city,
                    'area': area,
                    'designation': designation,
                    'caste': caste,
                    'gender': gender
                }
            }
        }, status=status.HTTP_200_OK)
        
    except ValueError:
        return Response({
            'success': False,
            'message': 'Invalid pagination parameters.',
            'errors': {'detail': 'Page and page_size must be valid integers.'}
        }, status=status.HTTP_400_BAD_REQUEST)
    
    except Exception as e:
        return Response({
            'success': False,
            'message': 'Search failed.',
            'errors': {'detail': str(e)}
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def new_labors(request):
    """
    Get new labors (joined within specified days)
    """
    try:
        days = int(request.GET.get('days', 30))
        page_size = min(int(request.GET.get('page_size', 20)), 100)
        page = int(request.GET.get('page', 1))
        
        # Get new labors
        labors = Labor.new_labors(days=days)
        labors = labors.select_related('created_by')
        
        # Calculate pagination
        total_count = labors.count()
        start_index = (page - 1) * page_size
        end_index = start_index + page_size
        
        labors = labors[start_index:end_index]
        
        serializer = LaborListSerializer(labors, many=True)
        
        return Response({
            'success': True,
            'data': {
                'labors': serializer.data,
                'pagination': {
                    'current_page': page,
                    'page_size': page_size,
                    'total_count': total_count,
                    'total_pages': (total_count + page_size - 1) // page_size,
                    'has_next': end_index < total_count,
                    'has_previous': page > 1
                },
                'days': days,
                'description': f'Labors joined within the last {days} days'
            }
        }, status=status.HTTP_200_OK)
        
    except ValueError:
        return Response({
            'success': False,
            'message': 'Invalid parameters.',
            'errors': {'detail': 'Days, page, and page_size must be valid integers.'}
        }, status=status.HTTP_400_BAD_REQUEST)
    
    except Exception as e:
        return Response({
            'success': False,
            'message': 'Failed to retrieve new labors.',
            'errors': {'detail': str(e)}
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def recent_labors(request):
    """
    Get recently joined labors (last 7 days by default)
    """
    try:
        days = int(request.GET.get('days', 7))
        page_size = min(int(request.GET.get('page_size', 20)), 100)
        page = int(request.GET.get('page', 1))
        
        # Get recent labors
        labors = Labor.recent_labors(days=days)
        labors = labors.select_related('created_by')
        
        # Calculate pagination
        total_count = labors.count()
        start_index = (page - 1) * page_size
        end_index = start_index + page_size
        
        labors = labors[start_index:end_index]
        
        serializer = LaborListSerializer(labors, many=True)
        
        return Response({
            'success': True,
            'data': {
                'labors': serializer.data,
                'pagination': {
                    'current_page': page,
                    'page_size': page_size,
                    'total_count': total_count,
                    'total_pages': (total_count + page_size - 1) // page_size,
                    'has_next': end_index < total_count,
                    'has_previous': page > 1
                },
                'days': days,
                'description': f'Labors joined in the last {days} days'
            }
        }, status=status.HTTP_200_OK)
        
    except ValueError:
        return Response({
            'success': False,
            'message': 'Invalid parameters.',
            'errors': {'detail': 'Days, page, and page_size must be valid integers.'}
        }, status=status.HTTP_400_BAD_REQUEST)
    
    except Exception as e:
        return Response({
            'success': False,
            'message': 'Failed to retrieve recent labors.',
            'errors': {'detail': str(e)}
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


# ==================== ANALYTICS AND REPORTING ====================

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def labor_statistics(request):
    """
    Get comprehensive labor statistics
    """
    try:
        stats = Labor.get_statistics()
        serializer = LaborStatsSerializer(stats)
        
        return Response({
            'success': True,
            'data': serializer.data
        }, status=status.HTTP_200_OK)
        
    except Exception as e:
        return Response({
            'success': False,
            'message': 'Failed to retrieve labor statistics.',
            'errors': {'detail': str(e)}
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def salary_report(request):
    """
    Get salary report and analytics
    """
    try:
        # Get active labors
        labors = Labor.active_labors()
        
        # Salary statistics
        salary_stats = labors.aggregate(
            total_salary_cost=Sum('salary'),
            avg_salary=Avg('salary'),
            min_salary=Min('salary'),
            max_salary=Max('salary'),
            total_labors=Count('id')
        )
        
        # Salary breakdown by designation
        designation_salary = list(
            labors.values('designation')
            .annotate(
                count=Count('id'),
                total_salary=Sum('salary'),
                avg_salary=Avg('salary')
            )
            .order_by('-total_salary')
        )
        
        # Salary breakdown by city
        city_salary = list(
            labors.values('city')
            .annotate(
                count=Count('id'),
                total_salary=Sum('salary'),
                avg_salary=Avg('salary')
            )
            .order_by('-total_salary')
        )
        
        # Salary breakdown by gender
        gender_salary = list(
            labors.values('gender')
            .annotate(
                count=Count('id'),
                total_salary=Sum('salary'),
                avg_salary=Avg('salary')
            )
            .order_by('-total_salary')
        )
        
        # Salary ranges
        salary_ranges = {
            'under_20k': labors.filter(salary__lt=20000).count(),
            '20k_to_35k': labors.filter(salary__gte=20000, salary__lt=35000).count(),
            '35k_to_50k': labors.filter(salary__gte=35000, salary__lt=50000).count(),
            '50k_to_75k': labors.filter(salary__gte=50000, salary__lt=75000).count(),
            'above_75k': labors.filter(salary__gte=75000).count(),
        }
        
        return Response({
            'success': True,
            'data': {
                'salary_statistics': salary_stats,
                'designation_breakdown': designation_salary,
                'city_breakdown': city_salary,
                'gender_breakdown': gender_salary,
                'salary_ranges': salary_ranges,
                'generated_at': timezone.now().isoformat()
            }
        }, status=status.HTTP_200_OK)
        
    except Exception as e:
        return Response({
            'success': False,
            'message': 'Failed to generate salary report.',
            'errors': {'detail': str(e)}
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def demographics_report(request):
    """
    Get demographics report and analytics
    """
    try:
        # Get active labors
        labors = Labor.active_labors()
        
        # Age statistics
        age_stats = labors.aggregate(
            avg_age=Avg('age'),
            min_age=Min('age'),
            max_age=Max('age'),
            total_labors=Count('id')
        )
        
        # Age groups
        age_groups = {
            '16_to_25': labors.filter(age__gte=16, age__lte=25).count(),
            '26_to_35': labors.filter(age__gte=26, age__lte=35).count(),
            '36_to_45': labors.filter(age__gte=36, age__lte=45).count(),
            '46_to_55': labors.filter(age__gte=46, age__lte=55).count(),
            'above_55': labors.filter(age__gt=55).count(),
        }
        
        # Gender breakdown
        gender_breakdown = list(
            labors.values('gender')
            .annotate(count=Count('id'))
            .order_by('gender')
        )
        
        # Caste breakdown (top 10)
        caste_breakdown = list(
            labors.exclude(caste='')
            .values('caste')
            .annotate(count=Count('id'))
            .order_by('-count')[:10]
        )
        
        # Location breakdown
        location_breakdown = list(
            labors.values('city', 'area')
            .annotate(count=Count('id'))
            .order_by('-count')[:15]
        )
        
        return Response({
            'success': True,
            'data': {
                'age_statistics': age_stats,
                'age_groups': age_groups,
                'gender_breakdown': gender_breakdown,
                'caste_breakdown': caste_breakdown,
                'location_breakdown': location_breakdown,
                'generated_at': timezone.now().isoformat()
            }
        }, status=status.HTTP_200_OK)
        
    except Exception as e:
        return Response({
            'success': False,
            'message': 'Failed to generate demographics report.',
            'errors': {'detail': str(e)}
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


# ==================== BULK OPERATIONS ====================

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def bulk_labor_actions(request):
    """
    Perform bulk actions on multiple labors
    """
    serializer = LaborBulkActionSerializer(data=request.data)
    
    if serializer.is_valid():
        try:
            with transaction.atomic():
                labor_ids = serializer.validated_data['labor_ids']
                action = serializer.validated_data['action']
                
                # Get labors
                labors = Labor.objects.filter(id__in=labor_ids)
                if labors.count() != len(labor_ids):
                    return Response({
                        'success': False,
                        'message': 'Some labors were not found.',
                        'errors': {'detail': 'One or more labor IDs are invalid.'}
                    }, status=status.HTTP_400_BAD_REQUEST)
                
                results = []
                
                # Perform action
                if action == 'activate':
                    updated_count = labors.update(is_active=True)
                    message = f'{updated_count} labors activated successfully.'
                
                elif action == 'deactivate':
                    updated_count = labors.update(is_active=False)
                    message = f'{updated_count} labors deactivated successfully.'
                
                elif action == 'update_salary':
                    salary_amount = serializer.validated_data.get('salary_amount')
                    salary_percentage = serializer.validated_data.get('salary_percentage')
                    
                    if salary_amount:
                        # Set fixed salary amount
                        updated_count = labors.update(salary=salary_amount)
                        message = f'{updated_count} labors salary updated to {salary_amount}.'
                    
                    elif salary_percentage:
                        # Apply percentage change
                        updated_count = 0
                        for labor in labors:
                            multiplier = 1 + (salary_percentage / 100)
                            new_salary = labor.salary * Decimal(str(multiplier))
                            labor.salary = new_salary.quantize(Decimal('0.01'))
                            labor.save(update_fields=['salary', 'updated_at'])
                            updated_count += 1
                        
                        message = f'{updated_count} labors salary updated by {salary_percentage}%.'
                
                # Get updated labor data
                updated_labors = Labor.objects.filter(id__in=labor_ids)
                for labor in updated_labors:
                    results.append({
                        'id': str(labor.id),
                        'name': labor.name,
                        'designation': labor.designation,
                        'salary': str(labor.salary),
                        'is_active': labor.is_active
                    })
                
                # Send custom signal
                labor_bulk_updated.send(
                    sender=Labor,
                    labors=list(updated_labors),
                    action=action
                )
                
                return Response({
                    'success': True,
                    'message': message,
                    'data': {
                        'action': action,
                        'updated_labors': results,
                        'total_updated': len(results)
                    }
                }, status=status.HTTP_200_OK)
                
        except Exception as e:
            return Response({
                'success': False,
                'message': 'Bulk action failed due to server error.',
                'errors': {'detail': str(e)}
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    
    return Response({
        'success': False,
        'message': 'Bulk action failed.',
        'errors': serializer.errors
    }, status=status.HTTP_400_BAD_REQUEST)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def duplicate_labor(request, labor_id):
    """
    Duplicate an existing labor (useful for creating similar labors)
    """
    try:
        original_labor = get_object_or_404(Labor, id=labor_id)
        
        # Get new data from request
        new_name = request.data.get('name')
        new_phone = request.data.get('phone_number')
        new_cnic = request.data.get('cnic')
        
        if not new_name:
            return Response({
                'success': False,
                'message': 'New labor name is required.',
                'errors': {'name': 'This field is required for duplication.'}
            }, status=status.HTTP_400_BAD_REQUEST)
        
        if not new_phone:
            return Response({
                'success': False,
                'message': 'New labor phone is required.',
                'errors': {'phone_number': 'This field is required for duplication.'}
            }, status=status.HTTP_400_BAD_REQUEST)
        
        if not new_cnic:
            return Response({
                'success': False,
                'message': 'New labor CNIC is required.',
                'errors': {'cnic': 'This field is required for duplication.'}
            }, status=status.HTTP_400_BAD_REQUEST)
        
        # Create duplicate with new contact info
        with transaction.atomic():
            duplicate_data = {
                'name': new_name.strip(),
                'cnic': new_cnic.strip(),
                'phone_number': new_phone.strip(),
                'caste': original_labor.caste,
                'designation': original_labor.designation,
                'joining_date': date.today(),  # Set today as joining date
                'salary': original_labor.salary,
                'area': original_labor.area,
                'city': original_labor.city,
                'gender': original_labor.gender,
                'age': request.data.get('age', original_labor.age),
                'created_by': request.user
            }
            
            # Validate using serializer
            serializer = LaborCreateSerializer(
                data=duplicate_data,
                context={'request': request}
            )
            
            if serializer.is_valid():
                duplicate_labor = serializer.save()
                
                return Response({
                    'success': True,
                    'message': 'Labor duplicated successfully.',
                    'data': LaborDetailSerializer(duplicate_labor).data
                }, status=status.HTTP_201_CREATED)
            else:
                return Response({
                    'success': False,
                    'message': 'Labor duplication failed.',
                    'errors': serializer.errors
                }, status=status.HTTP_400_BAD_REQUEST)
            
    except Labor.DoesNotExist:
        return Response({
            'success': False,
            'message': 'Labor not found.',
            'errors': {'detail': 'Labor with this ID does not exist.'}
        }, status=status.HTTP_404_NOT_FOUND)
    
    except Exception as e:
        return Response({
            'success': False,
            'message': 'Labor duplication failed.',
            'errors': {'detail': str(e)}
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def labor_payments(request, labor_id):
    """
    Get labor's payment history (placeholder for future integration)
    """
    try:
        labor = get_object_or_404(Labor, id=labor_id)
        
        # Placeholder response - will be implemented when Payment module is available
        return Response({
            'success': True,
            'message': 'Payment integration not yet implemented.',
            'data': {
                'labor_id': str(labor.id),
                'labor_name': labor.name,
                'advance_payments': [],
                'regular_payments': [],
                'total_advance_amount': 0.00,
                'total_payments_amount': 0.00,
                'remaining_advance_balance': 0.00,
                'last_payment_date': None,
                'note': 'Payment history will be available once Payment module is integrated.'
            }
        }, status=status.HTTP_200_OK)
        
    except Labor.DoesNotExist:
        return Response({
            'success': False,
            'message': 'Labor not found.',
            'errors': {'detail': 'Labor with this ID does not exist.'}
        }, status=status.HTTP_404_NOT_FOUND)
    