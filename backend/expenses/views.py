from rest_framework import status, generics, permissions
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.shortcuts import get_object_or_404
from django.db import transaction
from django.db.models import Q
from django.utils import timezone
from datetime import datetime, timedelta
from .models import Expense
from .serializers import (
    ExpenseSerializer,
    ExpenseCreateSerializer,
    ExpenseUpdateSerializer,
    ExpenseListSerializer,
    ExpenseStatisticsSerializer,
    BulkExpenseActionSerializer,
    MonthlySummarySerializer
)


@api_view(['GET', 'POST'])
@permission_classes([IsAuthenticated])
def expenses_list_create(request):
    """
    GET: List all expenses with filtering
    POST: Create new expense
    """
    if request.method == 'GET':
        expenses = Expense.objects.active()
        
        # Apply filters
        withdrawal_by = request.GET.get('withdrawal_by')
        category = request.GET.get('category')
        date_from = request.GET.get('date_from')
        date_to = request.GET.get('date_to')
        search = request.GET.get('search')
        
        if withdrawal_by:
            expenses = expenses.filter(withdrawal_by=withdrawal_by)
        
        if category:
            expenses = expenses.filter(category=category)
        
        if date_from:
            try:
                date_from = datetime.strptime(date_from, '%Y-%m-%d').date()
                expenses = expenses.filter(date__gte=date_from)
            except ValueError:
                pass
        
        if date_to:
            try:
                date_to = datetime.strptime(date_to, '%Y-%m-%d').date()
                expenses = expenses.filter(date__lte=date_to)
            except ValueError:
                pass
        
        if search:
            expenses = expenses.filter(
                Q(expense__icontains=search) |
                Q(description__icontains=search) |
                Q(category__icontains=search) |
                Q(notes__icontains=search)
            )
        
        # Ordering
        ordering = request.GET.get('ordering', '-date')
        expenses = expenses.order_by(ordering)
        
        # Pagination
        page = int(request.GET.get('page', 1))
        page_size = int(request.GET.get('page_size', 20))
        start = (page - 1) * page_size
        end = start + page_size
        
        total_count = expenses.count()
        expenses_page = expenses[start:end]
        
        serializer = ExpenseListSerializer(expenses_page, many=True)
        
        return Response({
            'success': True,
            'data': {
                'expenses': serializer.data,
                'pagination': {
                    'page': page,
                    'page_size': page_size,
                    'total_count': total_count,
                    'total_pages': (total_count + page_size - 1) // page_size,
                    'has_next': end < total_count,
                    'has_previous': page > 1
                }
            }
        }, status=status.HTTP_200_OK)
    
    elif request.method == 'POST':
        serializer = ExpenseCreateSerializer(
            data=request.data,
            context={'request': request}
        )
        
        if serializer.is_valid():
            try:
                with transaction.atomic():
                    expense = serializer.save()
                    
                    return Response({
                        'success': True,
                        'message': 'Expense created successfully.',
                        'data': ExpenseSerializer(expense).data
                    }, status=status.HTTP_201_CREATED)
                    
            except Exception as e:
                return Response({
                    'success': False,
                    'message': 'Expense creation failed due to server error.',
                    'errors': {'detail': str(e)}
                }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
        
        return Response({
            'success': False,
            'message': 'Expense creation failed.',
            'errors': serializer.errors
        }, status=status.HTTP_400_BAD_REQUEST)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def expense_detail(request, expense_id):
    """
    Get expense details
    """
    try:
        expense = get_object_or_404(Expense, id=expense_id, is_active=True)
        serializer = ExpenseSerializer(expense)
        
        return Response({
            'success': True,
            'data': serializer.data
        }, status=status.HTTP_200_OK)
        
    except Exception as e:
        return Response({
            'success': False,
            'message': 'Failed to retrieve expense.',
            'error': str(e)
        }, status=status.HTTP_404_NOT_FOUND)


@api_view(['PUT', 'PATCH'])
@permission_classes([IsAuthenticated])
def expense_update(request, expense_id):
    """
    Update expense
    """
    try:
        expense = get_object_or_404(Expense, id=expense_id, is_active=True)
        
        serializer = ExpenseUpdateSerializer(
            expense,
            data=request.data,
            partial=request.method == 'PATCH'
        )
        
        if serializer.is_valid():
            try:
                with transaction.atomic():
                    updated_expense = serializer.save()
                    
                    return Response({
                        'success': True,
                        'message': 'Expense updated successfully.',
                        'data': ExpenseSerializer(updated_expense).data
                    }, status=status.HTTP_200_OK)
                    
            except Exception as e:
                return Response({
                    'success': False,
                    'message': 'Expense update failed due to server error.',
                    'errors': {'detail': str(e)}
                }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
        
        return Response({
            'success': False,
            'message': 'Expense update failed.',
            'errors': serializer.errors
        }, status=status.HTTP_400_BAD_REQUEST)
        
    except Exception as e:
        return Response({
            'success': False,
            'message': 'Expense not found.',
            'error': str(e)
        }, status=status.HTTP_404_NOT_FOUND)


@api_view(['DELETE'])
@permission_classes([IsAuthenticated])
def expense_delete(request, expense_id):
    """
    Delete expense (soft delete)
    """
    try:
        expense = get_object_or_404(Expense, id=expense_id, is_active=True)
        
        with transaction.atomic():
            expense.delete()  # This performs soft delete
            
            return Response({
                'success': True,
                'message': 'Expense deleted successfully.'
            }, status=status.HTTP_200_OK)
            
    except Exception as e:
        return Response({
            'success': False,
            'message': 'Failed to delete expense.',
            'error': str(e)
        }, status=status.HTTP_404_NOT_FOUND)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def expenses_by_authority(request, authority):
    """
    Get expenses by withdrawal authority
    """
    try:
        # Validate authority
        valid_authorities = [choice[0] for choice in Expense.WITHDRAWAL_CHOICES]
        if authority not in valid_authorities:
            return Response({
                'success': False,
                'message': f'Invalid authority. Must be one of: {", ".join(valid_authorities)}'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        expenses = Expense.objects.by_authority(authority)
        
        # Apply date filtering if provided
        date_from = request.GET.get('date_from')
        date_to = request.GET.get('date_to')
        
        if date_from:
            try:
                date_from = datetime.strptime(date_from, '%Y-%m-%d').date()
                expenses = expenses.filter(date__gte=date_from)
            except ValueError:
                pass
        
        if date_to:
            try:
                date_to = datetime.strptime(date_to, '%Y-%m-%d').date()
                expenses = expenses.filter(date__lte=date_to)
            except ValueError:
                pass
        
        serializer = ExpenseListSerializer(expenses, many=True)
        
        return Response({
            'success': True,
            'data': {
                'authority': authority,
                'expenses': serializer.data,
                'count': len(serializer.data)
            }
        }, status=status.HTTP_200_OK)
        
    except Exception as e:
        return Response({
            'success': False,
            'message': 'Failed to retrieve expenses.',
            'error': str(e)
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def expenses_by_category(request, category):
    """
    Get expenses by category
    """
    try:
        expenses = Expense.objects.by_category(category)
        serializer = ExpenseListSerializer(expenses, many=True)
        
        return Response({
            'success': True,
            'data': {
                'category': category,
                'expenses': serializer.data,
                'count': len(serializer.data)
            }
        }, status=status.HTTP_200_OK)
        
    except Exception as e:
        return Response({
            'success': False,
            'message': 'Failed to retrieve expenses.',
            'error': str(e)
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def expenses_by_date_range(request):
    """
    Get expenses within date range
    """
    start_date = request.GET.get('start_date')
    end_date = request.GET.get('end_date')
    
    if not start_date or not end_date:
        return Response({
            'success': False,
            'message': 'Both start_date and end_date are required.'
        }, status=status.HTTP_400_BAD_REQUEST)
    
    try:
        start_date = datetime.strptime(start_date, '%Y-%m-%d').date()
        end_date = datetime.strptime(end_date, '%Y-%m-%d').date()
        
        if start_date > end_date:
            return Response({
                'success': False,
                'message': 'start_date cannot be greater than end_date.'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        expenses = Expense.objects.by_date_range(start_date, end_date)
        serializer = ExpenseListSerializer(expenses, many=True)
        
        # Calculate total amount
        total_amount = sum(expense.amount for expense in expenses)
        
        return Response({
            'success': True,
            'data': {
                'date_range': {
                    'start_date': start_date,
                    'end_date': end_date
                },
                'expenses': serializer.data,
                'count': len(serializer.data),
                'total_amount': float(total_amount),
                'formatted_total': f"PKR {total_amount:,.2f}"
            }
        }, status=status.HTTP_200_OK)
        
    except ValueError:
        return Response({
            'success': False,
            'message': 'Invalid date format. Use YYYY-MM-DD.'
        }, status=status.HTTP_400_BAD_REQUEST)
    except Exception as e:
        return Response({
            'success': False,
            'message': 'Failed to retrieve expenses.',
            'error': str(e)
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def expense_statistics(request):
    """
    Get comprehensive expense statistics
    """
    try:
        serializer = ExpenseStatisticsSerializer({})
        
        return Response({
            'success': True,
            'data': serializer.data
        }, status=status.HTTP_200_OK)
        
    except Exception as e:
        return Response({
            'success': False,
            'message': 'Failed to retrieve statistics.',
            'error': str(e)
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def monthly_summary(request):
    """
    Get monthly expense summary
    """
    try:
        month = request.GET.get('month', timezone.now().month)
        year = request.GET.get('year', timezone.now().year)
        
        try:
            month = int(month)
            year = int(year)
        except ValueError:
            return Response({
                'success': False,
                'message': 'Invalid month or year format.'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        if month < 1 or month > 12:
            return Response({
                'success': False,
                'message': 'Month must be between 1 and 12.'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        serializer = MonthlySummarySerializer({'month': month, 'year': year})
        
        return Response({
            'success': True,
            'data': serializer.data
        }, status=status.HTTP_200_OK)
        
    except Exception as e:
        return Response({
            'success': False,
            'message': 'Failed to retrieve monthly summary.',
            'error': str(e)
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def bulk_actions(request):
    """
    Perform bulk actions on expenses
    """
    serializer = BulkExpenseActionSerializer(data=request.data)
    
    if serializer.is_valid():
        try:
            action = serializer.validated_data['action']
            expense_ids = serializer.validated_data['expense_ids']
            
            with transaction.atomic():
                expenses = Expense.objects.filter(id__in=expense_ids, is_active=True)
                
                if action == 'delete':
                    for expense in expenses:
                        expense.delete()  # Soft delete
                    message = f'Successfully deleted {len(expenses)} expenses.'
                
                elif action == 'deactivate':
                    expenses.update(is_active=False)
                    message = f'Successfully deactivated {len(expenses)} expenses.'
                
                elif action == 'activate':
                    # For activate, we need to include inactive expenses
                    expenses = Expense.objects.filter(id__in=expense_ids)
                    expenses.update(is_active=True)
                    message = f'Successfully activated {len(expenses)} expenses.'
                
                return Response({
                    'success': True,
                    'message': message,
                    'data': {
                        'action': action,
                        'affected_count': len(expenses)
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


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def recent_expenses(request):
    """
    Get recent expenses
    """
    try:
        limit = int(request.GET.get('limit', 10))
        if limit > 100:  # Prevent excessive requests
            limit = 100
        
        expenses = Expense.objects.recent(limit)
        serializer = ExpenseListSerializer(expenses, many=True)
        
        return Response({
            'success': True,
            'data': {
                'expenses': serializer.data,
                'count': len(serializer.data)
            }
        }, status=status.HTTP_200_OK)
        
    except Exception as e:
        return Response({
            'success': False,
            'message': 'Failed to retrieve recent expenses.',
            'error': str(e)
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


# Class-based views alternative (more DRF standard)
class ExpenseListCreateAPIView(generics.ListCreateAPIView):
    """Class-based view for listing and creating expenses"""
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        queryset = Expense.objects.active()
        
        # Apply filters
        withdrawal_by = self.request.query_params.get('withdrawal_by')
        category = self.request.query_params.get('category')
        date_from = self.request.query_params.get('date_from')
        date_to = self.request.query_params.get('date_to')
        search = self.request.query_params.get('search')
        
        if withdrawal_by:
            queryset = queryset.filter(withdrawal_by=withdrawal_by)
        
        if category:
            queryset = queryset.filter(category=category)
        
        if date_from:
            try:
                date_from = datetime.strptime(date_from, '%Y-%m-%d').date()
                queryset = queryset.filter(date__gte=date_from)
            except ValueError:
                pass
        
        if date_to:
            try:
                date_to = datetime.strptime(date_to, '%Y-%m-%d').date()
                queryset = queryset.filter(date__lte=date_to)
            except ValueError:
                pass
        
        if search:
            queryset = queryset.filter(
                Q(expense__icontains=search) |
                Q(description__icontains=search) |
                Q(category__icontains=search) |
                Q(notes__icontains=search)
            )
        
        # Ordering
        ordering = self.request.query_params.get('ordering', '-date')
        queryset = queryset.order_by(ordering)
        
        return queryset
    
    def get_serializer_class(self):
        if self.request.method == 'POST':
            return ExpenseCreateSerializer
        return ExpenseListSerializer
    
    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        expense = serializer.save()
        
        return Response({
            'success': True,
            'message': 'Expense created successfully.',
            'data': ExpenseSerializer(expense).data
        }, status=status.HTTP_201_CREATED)
    
    def list(self, request, *args, **kwargs):
        queryset = self.filter_queryset(self.get_queryset())
        
        # Pagination
        page = self.paginate_queryset(queryset)
        if page is not None:
            serializer = self.get_serializer(page, many=True)
            return self.get_paginated_response({
                'success': True,
                'data': serializer.data
            })
        
        serializer = self.get_serializer(queryset, many=True)
        return Response({
            'success': True,
            'data': serializer.data
        })


class ExpenseDetailAPIView(generics.RetrieveUpdateDestroyAPIView):
    """Class-based view for expense detail operations"""
    queryset = Expense.objects.filter(is_active=True)
    permission_classes = [IsAuthenticated]
    lookup_field = 'id'
    lookup_url_kwarg = 'expense_id'
    
    def get_serializer_class(self):
        if self.request.method in ['PUT', 'PATCH']:
            return ExpenseUpdateSerializer
        return ExpenseSerializer
    
    def retrieve(self, request, *args, **kwargs):
        instance = self.get_object()
        serializer = self.get_serializer(instance)
        return Response({
            'success': True,
            'data': serializer.data
        })
    
    def update(self, request, *args, **kwargs):
        partial = kwargs.pop('partial', False)
        instance = self.get_object()
        serializer = self.get_serializer(instance, data=request.data, partial=partial)
        serializer.is_valid(raise_exception=True)
        updated_expense = serializer.save()
        
        return Response({
            'success': True,
            'message': 'Expense updated successfully.',
            'data': ExpenseSerializer(updated_expense).data
        })
    
    def destroy(self, request, *args, **kwargs):
        instance = self.get_object()
        instance.delete()  # Soft delete
        
        return Response({
            'success': True,
            'message': 'Expense deleted successfully.'
        }, status=status.HTTP_200_OK)
    