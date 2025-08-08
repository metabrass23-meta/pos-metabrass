from django.shortcuts import get_object_or_404
from django.http import JsonResponse, HttpResponse
from django.views.decorators.http import require_http_methods, require_GET, require_POST
from django.views.decorators.csrf import csrf_exempt
from django.contrib.auth.decorators import login_required
from django.core.paginator import Paginator, EmptyPage, PageNotAnInteger
from django.db.models import Q, Count, Sum
from django.utils import timezone
from datetime import datetime, timedelta
import json
import csv
import uuid
from .models import Vendor, VendorNote
from .serializers import (
    VendorListSerializer, VendorDetailSerializer, 
    VendorCreateUpdateSerializer, VendorNoteSerializer
)


def paginate_queryset(request, queryset, per_page=10):
    """Helper function to paginate queryset"""
    page = request.GET.get('page', 1)
    per_page = request.GET.get('per_page', per_page)
    
    try:
        per_page = min(int(per_page), 100)  # Limit to 100 items per page
    except (ValueError, TypeError):
        per_page = 10
    
    paginator = Paginator(queryset, per_page)
    
    try:
        page_obj = paginator.page(page)
    except PageNotAnInteger:
        page_obj = paginator.page(1)
    except EmptyPage:
        page_obj = paginator.page(paginator.num_pages)
    
    return {
        'results': list(page_obj),
        'pagination': {
            'current_page': page_obj.number,
            'total_pages': paginator.num_pages,
            'total_items': paginator.count,
            'per_page': per_page,
            'has_next': page_obj.has_next(),
            'has_previous': page_obj.has_previous(),
        }
    }


def json_response(data, status=200):
    """Helper function to return JSON response"""
    return JsonResponse(data, status=status)


def error_response(message, status=400, errors=None):
    """Helper function to return error response"""
    response_data = {'error': message}
    if errors:
        response_data['errors'] = errors
    return JsonResponse(response_data, status=status)


# Core CRUD Operations

@require_GET
@login_required
def list_vendors(request):
    """List all vendors with filtering and pagination"""
    try:
        queryset = Vendor.objects.all()
        
        # Apply filters
        search_query = request.GET.get('search', '').strip()
        if search_query:
            queryset = queryset.filter(
                Q(name__icontains=search_query) |
                Q(business_name__icontains=search_query) |
                Q(phone__icontains=search_query) |
                Q(cnic__icontains=search_query)
            )
        
        # Filter by active status
        is_active = request.GET.get('is_active')
        if is_active is not None:
            queryset = queryset.filter(is_active=is_active.lower() == 'true')
        
        # Filter by city
        city = request.GET.get('city')
        if city:
            queryset = queryset.filter(city__icontains=city)
        
        # Filter by area
        area = request.GET.get('area')
        if area:
            queryset = queryset.filter(area__icontains=area)
        
        # Date range filters
        created_after = request.GET.get('created_after')
        if created_after:
            try:
                date_after = datetime.strptime(created_after, '%Y-%m-%d').date()
                queryset = queryset.filter(created_at__date__gte=date_after)
            except ValueError:
                pass
        
        created_before = request.GET.get('created_before')
        if created_before:
            try:
                date_before = datetime.strptime(created_before, '%Y-%m-%d').date()
                queryset = queryset.filter(created_at__date__lte=date_before)
            except ValueError:
                pass
        
        # Ordering
        ordering = request.GET.get('ordering', '-created_at')
        if ordering:
            queryset = queryset.order_by(ordering)
        
        # Paginate results
        paginated_data = paginate_queryset(request, queryset)
        
        # Serialize data
        serializer = VendorListSerializer(paginated_data['results'], many=True)
        
        return json_response({
            'data': serializer.data,
            'pagination': paginated_data['pagination']
        })
        
    except Exception as e:
        return error_response(f'Failed to retrieve vendors: {str(e)}', 500)


@require_POST
@login_required
@csrf_exempt
def create_vendor(request):
    """Create a new vendor"""
    try:
        data = json.loads(request.body)
        
        # Add created_by to data
        data['created_by'] = request.user.id if hasattr(request, 'user') else None
        
        serializer = VendorCreateUpdateSerializer(data=data)
        if serializer.is_valid():
            vendor = serializer.save(created_by=request.user)
            
            # Return detailed vendor data
            detail_serializer = VendorDetailSerializer(vendor)
            
            return json_response({
                'message': 'Vendor created successfully',
                'data': detail_serializer.data
            }, status=201)
        else:
            return error_response(
                'Validation failed',
                status=400,
                errors=serializer.errors
            )
            
    except json.JSONDecodeError:
        return error_response('Invalid JSON data', 400)
    except Exception as e:
        return error_response(f'Failed to create vendor: {str(e)}', 500)


@require_GET
@login_required
def get_vendor(request, vendor_id):
    """Get a single vendor by ID"""
    try:
        vendor = get_object_or_404(Vendor, id=vendor_id)
        serializer = VendorDetailSerializer(vendor)
        
        return json_response({
            'data': serializer.data
        })
        
    except Exception as e:
        return error_response(f'Failed to retrieve vendor: {str(e)}', 500)


@require_http_methods(["PUT", "PATCH"])
@login_required
@csrf_exempt
def update_vendor(request, vendor_id):
    """Update an existing vendor"""
    try:
        vendor = get_object_or_404(Vendor, id=vendor_id)
        data = json.loads(request.body)
        
        serializer = VendorCreateUpdateSerializer(
            vendor, 
            data=data, 
            partial=request.method == 'PATCH'
        )
        
        if serializer.is_valid():
            updated_vendor = serializer.save()
            
            # Return updated vendor data
            detail_serializer = VendorDetailSerializer(updated_vendor)
            
            return json_response({
                'message': 'Vendor updated successfully',
                'data': detail_serializer.data
            })
        else:
            return error_response(
                'Validation failed',
                status=400,
                errors=serializer.errors
            )
            
    except json.JSONDecodeError:
        return error_response('Invalid JSON data', 400)
    except Exception as e:
        return error_response(f'Failed to update vendor: {str(e)}', 500)


@require_http_methods(["DELETE"])
@login_required
@csrf_exempt
def delete_vendor(request, vendor_id):
    """Permanently delete a vendor (hard delete)"""
    try:
        vendor = get_object_or_404(Vendor, id=vendor_id)
        vendor_name = vendor.name
        
        # Check if vendor has any associated payments/transactions
        # This would be implemented when Payment model is available
        
        vendor.delete()
        
        return json_response({
            'message': f'Vendor "{vendor_name}" has been permanently deleted'
        })
        
    except Exception as e:
        return error_response(f'Failed to delete vendor: {str(e)}', 500)


@require_POST
@login_required
@csrf_exempt
def soft_delete_vendor(request, vendor_id):
    """Soft delete a vendor"""
    try:
        vendor = get_object_or_404(Vendor, id=vendor_id)
        
        if not vendor.is_active:
            return error_response('Vendor is already inactive', 400)
        
        vendor.soft_delete()
        
        return json_response({
            'message': f'Vendor "{vendor.name}" has been soft deleted',
            'vendor_id': str(vendor.id)
        })
        
    except Exception as e:
        return error_response(f'Failed to soft delete vendor: {str(e)}', 500)


@require_POST
@login_required
@csrf_exempt
def restore_vendor(request, vendor_id):
    """Restore a soft deleted vendor"""
    try:
        vendor = get_object_or_404(Vendor, id=vendor_id)
        
        if vendor.is_active:
            return error_response('Vendor is already active', 400)
        
        vendor.restore()
        
        return json_response({
            'message': f'Vendor "{vendor.name}" has been restored',
            'vendor_id': str(vendor.id)
        })
        
    except Exception as e:
        return error_response(f'Failed to restore vendor: {str(e)}', 500)


# Search and Filtering

@require_GET
@login_required
def search_vendors(request):
    """Advanced search functionality for vendors"""
    try:
        search_query = request.GET.get('q', '').strip()
        
        if not search_query:
            return error_response('Search query is required', 400)
        
        queryset = Vendor.objects.search(search_query)
        
        # Additional filters
        city = request.GET.get('city')
        if city:
            queryset = queryset.filter(city__icontains=city)
        
        area = request.GET.get('area')
        if area:
            queryset = queryset.filter(area__icontains=area)
        
        is_active = request.GET.get('is_active')
        if is_active is not None:
            queryset = queryset.filter(is_active=is_active.lower() == 'true')
        
        # Date filters
        created_after = request.GET.get('created_after')
        if created_after:
            try:
                date_after = datetime.strptime(created_after, '%Y-%m-%d').date()
                queryset = queryset.filter(created_at__date__gte=date_after)
            except ValueError:
                pass
        
        created_before = request.GET.get('created_before')
        if created_before:
            try:
                date_before = datetime.strptime(created_before, '%Y-%m-%d').date()
                queryset = queryset.filter(created_at__date__lte=date_before)
            except ValueError:
                pass
        
        # Ordering
        ordering = request.GET.get('ordering', '-created_at')
        queryset = queryset.order_by(ordering)
        
        # Paginate results
        paginated_data = paginate_queryset(request, queryset)
        
        # Serialize data
        serializer = VendorListSerializer(paginated_data['results'], many=True)
        
        return json_response({
            'data': serializer.data,
            'pagination': paginated_data['pagination'],
            'search_query': search_query
        })
        
    except Exception as e:
        return error_response(f'Search failed: {str(e)}', 500)


@require_GET
@login_required
def vendors_by_city(request, city_name):
    """Get all vendors in a specific city"""
    try:
        queryset = Vendor.objects.by_city(city_name)
        
        # Paginate results
        paginated_data = paginate_queryset(request, queryset)
        
        # Serialize data
        serializer = VendorListSerializer(paginated_data['results'], many=True)
        
        return json_response({
            'data': serializer.data,
            'pagination': paginated_data['pagination'],
            'city': city_name
        })
        
    except Exception as e:
        return error_response(f'Failed to get vendors by city: {str(e)}', 500)


@require_GET
@login_required
def vendors_by_area(request, area_name):
    """Get all vendors in a specific area"""
    try:
        queryset = Vendor.objects.by_area(area_name)
        
        # Paginate results
        paginated_data = paginate_queryset(request, queryset)
        
        # Serialize data
        serializer = VendorListSerializer(paginated_data['results'], many=True)
        
        return json_response({
            'data': serializer.data,
            'pagination': paginated_data['pagination'],
            'area': area_name
        })
        
    except Exception as e:
        return error_response(f'Failed to get vendors by area: {str(e)}', 500)


@require_GET
@login_required
def recent_vendors(request):
    """Get recently added vendors"""
    try:
        days = int(request.GET.get('days', 30))
        queryset = Vendor.objects.recent(days)
        
        # Paginate results
        paginated_data = paginate_queryset(request, queryset)
        
        # Serialize data
        serializer = VendorListSerializer(paginated_data['results'], many=True)
        
        return json_response({
            'data': serializer.data,
            'pagination': paginated_data['pagination'],
            'days': days
        })
        
    except ValueError:
        return error_response('Invalid days parameter', 400)
    except Exception as e:
        return error_response(f'Failed to get recent vendors: {str(e)}', 500)

        # Statistics and Analytics

@require_GET
@login_required
def vendor_statistics(request):
    """Get comprehensive vendor statistics for dashboard"""
    try:
        now = timezone.now()
        today = now.date()
        this_week_start = today - timedelta(days=today.weekday())
        this_month_start = today.replace(day=1)
        
        # Basic counts
        total_vendors = Vendor.objects.count()
        active_vendors = Vendor.objects.filter(is_active=True).count()
        inactive_vendors = Vendor.objects.filter(is_active=False).count()
        
        # Time-based counts
        new_vendors_today = Vendor.objects.filter(
            created_at__date=today
        ).count()
        
        new_vendors_this_week = Vendor.objects.filter(
            created_at__date__gte=this_week_start
        ).count()
        
        new_vendors_this_month = Vendor.objects.filter(
            created_at__date__gte=this_month_start
        ).count()
        
        # Top cities
        top_cities = list(
            Vendor.objects.filter(is_active=True)
            .values('city')
            .annotate(count=Count('id'))
            .order_by('-count')[:10]
        )
        
        # Vendors by month (last 12 months)
        vendors_by_month = []
        for i in range(12):
            month_date = (today.replace(day=1) - timedelta(days=32*i)).replace(day=1)
            next_month = (month_date + timedelta(days=32)).replace(day=1)
            
            count = Vendor.objects.filter(
                created_at__date__gte=month_date,
                created_at__date__lt=next_month
            ).count()
            
            vendors_by_month.append({
                'month': month_date.strftime('%Y-%m'),
                'count': count,
                'month_name': month_date.strftime('%B %Y')
            })
        
        vendors_by_month.reverse()
        
        # Growth statistics
        last_month_start = (this_month_start - timedelta(days=1)).replace(day=1)
        last_month_vendors = Vendor.objects.filter(
            created_at__date__gte=last_month_start,
            created_at__date__lt=this_month_start
        ).count()
        
        growth_rate = 0
        if last_month_vendors > 0:
            growth_rate = ((new_vendors_this_month - last_month_vendors) / last_month_vendors) * 100
        
        statistics = {
            'total_vendors': total_vendors,
            'active_vendors': active_vendors,
            'inactive_vendors': inactive_vendors,
            'new_vendors_today': new_vendors_today,
            'new_vendors_this_week': new_vendors_this_week,
            'new_vendors_this_month': new_vendors_this_month,
            'monthly_growth_rate': round(growth_rate, 2),
            'top_cities': top_cities,
            'vendors_by_month': vendors_by_month
        }
        
        return json_response({'data': statistics})
        
    except Exception as e:
        return error_response(f'Failed to get statistics: {str(e)}', 500)


# Integration Endpoints

@require_GET
@login_required
def vendor_payments(request, vendor_id):
    """Get vendor's payment history (integration endpoint)"""
    try:
        vendor = get_object_or_404(Vendor, id=vendor_id)
        
        # This will be implemented when Payment model is available
        # For now, return empty data structure
        
        payment_data = {
            'vendor_id': str(vendor.id),
            'vendor_name': vendor.name,
            'payments': [],  # Will be populated from Payment model
            'summary': {
                'total_payments': vendor.get_payments_count(),
                'total_amount': vendor.get_total_payments_amount(),
                'first_payment_date': None,  # Will be implemented
                'last_payment_date': vendor.get_last_payment_date(),
                'average_amount': vendor.get_average_payment_amount()
            }
        }
        
        return json_response({'data': payment_data})
        
    except Exception as e:
        return error_response(f'Failed to get vendor payments: {str(e)}', 500)


@require_GET
@login_required
def vendor_transactions(request, vendor_id):
    """Get vendor's transaction summary (integration endpoint)"""
    try:
        vendor = get_object_or_404(Vendor, id=vendor_id)
        
        # This will be implemented when Transaction/Payment models are available
        transaction_data = {
            'vendor_id': str(vendor.id),
            'vendor_name': vendor.name,
            'transactions': [],  # Will be populated from Transaction model
            'summary': {
                'total_transactions': 0,
                'total_amount': 0.00,
                'pending_amount': 0.00,
                'paid_amount': 0.00,
                'last_transaction_date': None
            }
        }
        
        return json_response({'data': transaction_data})
        
    except Exception as e:
        return error_response(f'Failed to get vendor transactions: {str(e)}', 500)


# Bulk Operations

@require_POST
@login_required
@csrf_exempt
def bulk_vendor_actions(request):
    """Handle bulk actions on vendors"""
    try:
        data = json.loads(request.body)
        
        vendor_ids = data.get('vendor_ids', [])
        action = data.get('action', '')
        
        if not vendor_ids:
            return error_response('vendor_ids are required', 400)
        
        if not action:
            return error_response('action is required', 400)
        
        # Validate vendor IDs
        try:
            vendor_ids = [uuid.UUID(vid) for vid in vendor_ids]
        except ValueError:
            return error_response('Invalid vendor ID format', 400)
        
        vendors = Vendor.objects.filter(id__in=vendor_ids)
        
        if vendors.count() != len(vendor_ids):
            return error_response('Some vendor IDs do not exist', 400)
        
        if action == 'soft_delete':
            count = 0
            for vendor in vendors:
                if vendor.is_active:
                    vendor.soft_delete()
                    count += 1
            
            return json_response({
                'message': f'Successfully soft deleted {count} vendors',
                'affected_count': count
            })
        
        elif action == 'restore':
            count = 0
            for vendor in vendors:
                if not vendor.is_active:
                    vendor.restore()
                    count += 1
            
            return json_response({
                'message': f'Successfully restored {count} vendors',
                'affected_count': count
            })
        
        elif action == 'export':
            # Generate CSV export for selected vendors
            response = HttpResponse(content_type='text/csv')
            response['Content-Disposition'] = 'attachment; filename="vendors_export.csv"'
            
            writer = csv.writer(response)
            writer.writerow([
                'Name', 'Business Name', 'CNIC', 'Phone', 
                'City', 'Area', 'Status', 'Created At'
            ])
            
            for vendor in vendors:
                writer.writerow([
                    vendor.name,
                    vendor.business_name,
                    vendor.cnic,
                    vendor.phone,
                    vendor.city,
                    vendor.area,
                    'Active' if vendor.is_active else 'Inactive',
                    vendor.created_at.strftime('%Y-%m-%d %H:%M:%S')
                ])
            
            return response
        
        else:
            return error_response('Invalid action specified', 400)
        
    except json.JSONDecodeError:
        return error_response('Invalid JSON data', 400)
    except Exception as e:
        return error_response(f'Bulk action failed: {str(e)}', 500)


# Import/Export Operations

@require_POST
@login_required
@csrf_exempt
def import_vendors(request):
    """Import vendor data from CSV/Excel"""
    try:
        if 'file' not in request.FILES:
            return error_response('No file provided', 400)
        
        uploaded_file = request.FILES['file']
        skip_duplicates = request.POST.get('skip_duplicates', 'true').lower() == 'true'
        update_existing = request.POST.get('update_existing', 'false').lower() == 'true'
        
        # Validate file
        allowed_extensions = ['.csv', '.xlsx', '.xls']
        file_extension = '.' + uploaded_file.name.lower().split('.')[-1]
        
        if file_extension not in allowed_extensions:
            return error_response(
                f'Unsupported file format. Allowed formats: {", ".join(allowed_extensions)}',
                400
            )
        
        # Check file size (limit to 10MB)
        if uploaded_file.size > 10 * 1024 * 1024:
            return error_response('File too large. Maximum size is 10MB.', 400)
        
        # Process file based on extension
        try:
            import pandas as pd
            
            if file_extension == '.csv':
                df = pd.read_csv(uploaded_file)
            elif file_extension in ['.xlsx', '.xls']:
                df = pd.read_excel(uploaded_file)
            else:
                return error_response('Unsupported file format', 400)
            
            # Process the data
            results = process_import_data(df, skip_duplicates, update_existing, request.user)
            
            return json_response({
                'message': 'Import completed',
                'results': results
            })
            
        except Exception as e:
            return error_response(f'Failed to process file: {str(e)}', 400)
            
    except Exception as e:
        return error_response(f'Import failed: {str(e)}', 500)


def process_import_data(df, skip_duplicates, update_existing, user):
    """Process imported data and create/update vendors"""
    results = {
        'total_rows': len(df),
        'created': 0,
        'updated': 0,
        'skipped': 0,
        'errors': []
    }
    
    # Expected columns
    required_columns = ['name', 'business_name', 'cnic', 'phone', 'city', 'area']
    
    # Check if all required columns are present
    missing_columns = [col for col in required_columns if col not in df.columns]
    if missing_columns:
        results['errors'].append(f'Missing required columns: {", ".join(missing_columns)}')
        return results
    
    for index, row in df.iterrows():
        try:
            # Extract vendor data
            vendor_data = {
                'name': str(row['name']).strip(),
                'business_name': str(row['business_name']).strip(),
                'cnic': str(row['cnic']).strip(),
                'phone': str(row['phone']).strip(),
                'city': str(row['city']).strip(),
                'area': str(row['area']).strip(),
                'is_active': True
            }
            
            # Check for existing vendor with same CNIC
            existing_vendor = Vendor.objects.filter(cnic=vendor_data['cnic']).first()
            
            if existing_vendor:
                if update_existing:
                    # Update existing vendor
                    for key, value in vendor_data.items():
                        setattr(existing_vendor, key, value)
                    existing_vendor.save()
                    results['updated'] += 1
                else:
                    # Skip duplicate
                    results['skipped'] += 1
            else:
                # Create new vendor
                vendor_data['created_by'] = user
                vendor = Vendor(**vendor_data)
                vendor.full_clean()  # Validate the model
                vendor.save()
                results['created'] += 1
                
        except Exception as e:
            error_msg = f'Row {index + 2}: {str(e)}'
            results['errors'].append(error_msg)
    
    return results


@require_POST
@login_required
@csrf_exempt
def export_vendors(request):
    """Export vendor data in various formats"""
    try:
        data = json.loads(request.body)
        
        export_format = data.get('format', 'csv')
        include_inactive = data.get('include_inactive', False)
        fields = data.get('fields', [
            'name', 'business_name', 'cnic', 'phone',
            'city', 'area', 'created_at', 'updated_at'
        ])
        
        # Build queryset
        queryset = Vendor.objects.all()
        if not include_inactive:
            queryset = queryset.filter(is_active=True)
        
        # Apply date range filter if provided
        date_range = data.get('date_range')
        if date_range:
            try:
                start_date, end_date = date_range.split(',')
                start_date = datetime.strptime(start_date.strip(), '%Y-%m-%d').date()
                end_date = datetime.strptime(end_date.strip(), '%Y-%m-%d').date()
                queryset = queryset.filter(
                    created_at__date__gte=start_date,
                    created_at__date__lte=end_date
                )
            except (ValueError, AttributeError):
                pass
        
        # Generate export based on format
        if export_format == 'csv':
            return export_csv(queryset, fields)
        elif export_format == 'excel':
            return export_excel(queryset, fields)
        elif export_format == 'pdf':
            return export_pdf(queryset, fields)
        
        return error_response('Invalid export format', 400)
        
    except json.JSONDecodeError:
        return error_response('Invalid JSON data', 400)
    except Exception as e:
        return error_response(f'Export failed: {str(e)}', 500)


def export_csv(queryset, fields):
    """Export data as CSV"""
    response = HttpResponse(content_type='text/csv')
    response['Content-Disposition'] = 'attachment; filename="vendors_export.csv"'
    
    writer = csv.writer(response)
    
    # Header row
    headers = [field.replace('_', ' ').title() for field in fields]
    writer.writerow(headers)
    
    # Data rows
    for vendor in queryset:
        row = []
        for field in fields:
            value = getattr(vendor, field, '')
            if hasattr(value, 'strftime'):  # DateTime fields
                value = value.strftime('%Y-%m-%d %H:%M:%S')
            row.append(str(value))
        writer.writerow(row)
    
    return response


def export_excel(queryset, fields):
    """Export data as Excel"""
    try:
        import pandas as pd
        import io
        
        output = io.BytesIO()
        
        # Create DataFrame
        data = []
        for vendor in queryset:
            row = {}
            for field in fields:
                value = getattr(vendor, field, '')
                row[field.replace('_', ' ').title()] = value
            data.append(row)
        
        df = pd.DataFrame(data)
        df.to_excel(output, index=False, engine='openpyxl')
        output.seek(0)
        
        response = HttpResponse(
            output.getvalue(),
            content_type='application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
        )
        response['Content-Disposition'] = 'attachment; filename="vendors_export.xlsx"'
        
        return response
        
    except ImportError:
        return error_response('Excel export requires pandas and openpyxl', 500)
    except Exception as e:
        return error_response(f'Excel export failed: {str(e)}', 500)


def export_pdf(queryset, fields):
    """Export data as PDF - Basic implementation"""
    response = HttpResponse(content_type='text/plain')
    response['Content-Disposition'] = 'attachment; filename="vendors_export.txt"'
    
    content = "VENDOR EXPORT REPORT\n"
    content += "=" * 50 + "\n\n"
    
    for vendor in queryset:
        content += f"Name: {vendor.name}\n"
        content += f"Business: {vendor.business_name}\n"
        content += f"CNIC: {vendor.cnic}\n"
        content += f"Phone: {vendor.phone}\n"
        content += f"Location: {vendor.full_address}\n"
        content += f"Status: {'Active' if vendor.is_active else 'Inactive'}\n"
        content += f"Created: {vendor.created_at.strftime('%Y-%m-%d')}\n"
        content += "-" * 30 + "\n"
    
    response.write(content)
    return response


# Helper Endpoints

@require_GET
@login_required
def vendor_cities_list(request):
    """Get list of all cities with vendor counts"""
    try:
        cities = (
            Vendor.objects
            .filter(is_active=True)
            .values('city')
            .annotate(count=Count('id'))
            .order_by('city')
        )
        
        return json_response({'data': list(cities)})
        
    except Exception as e:
        return error_response(f'Failed to get cities: {str(e)}', 500)


@require_GET
@login_required
def vendor_areas_list(request):
    """Get list of all areas with vendor counts"""
    try:
        city = request.GET.get('city')
        queryset = Vendor.objects.filter(is_active=True)
        
        if city:
            queryset = queryset.filter(city__icontains=city)
        
        areas = (
            queryset
            .values('area', 'city')
            .annotate(count=Count('id'))
            .order_by('city', 'area')
        )
        
        return json_response({'data': list(areas)})
        
    except Exception as e:
        return error_response(f'Failed to get areas: {str(e)}', 500)


@require_POST
@login_required
@csrf_exempt
def add_vendor_note(request, vendor_id):
    """Add a note to a vendor"""
    try:
        vendor = get_object_or_404(Vendor, id=vendor_id)
        data = json.loads(request.body)
        
        note_text = data.get('note', '').strip()
        if not note_text:
            return error_response('Note text is required', 400)
        
        note = VendorNote.objects.create(
            vendor=vendor,
            note=note_text,
            created_by=request.user
        )
        
        serializer = VendorNoteSerializer(note)
        
        return json_response({
            'message': 'Note added successfully',
            'data': serializer.data
        }, status=201)
        
    except json.JSONDecodeError:
        return error_response('Invalid JSON data', 400)
    except Exception as e:
        return error_response(f'Failed to add note: {str(e)}', 500)
    