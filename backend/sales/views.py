from rest_framework import status, generics, permissions
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.db import transaction
from django.shortcuts import get_object_or_404
from django.db.models import Q, Sum, Count
from decimal import Decimal
from .models import Sales, SaleItem
from .serializers import (
    SalesSerializer, SalesCreateSerializer, SalesUpdateSerializer, SalesListSerializer,
    SaleItemSerializer, SaleItemCreateSerializer, SaleItemUpdateSerializer, SaleItemListSerializer,
    SalesPaymentSerializer, SalesStatusUpdateSerializer, SalesBulkActionSerializer,
    SalesStatisticsSerializer, OrderToSaleConversionSerializer
)
from customers.models import Customer
from products.models import Product
from orders.models import Order
from order_items.models import OrderItem
from .models import Invoice, Receipt
from .serializers import (
    InvoiceCreateSerializer, InvoiceSerializer, InvoiceUpdateSerializer, InvoiceListSerializer,
    ReceiptCreateSerializer, ReceiptSerializer, ReceiptUpdateSerializer, ReceiptListSerializer
)
from django.utils import timezone


# Function-based views for Sales

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def list_sales(request):
    """List all sales with filtering, search, and pagination"""
    try:
        # Get query parameters
        show_inactive = request.GET.get('show_inactive', 'false').lower() == 'true'
        page_size = min(int(request.GET.get('page_size', 20)), 100)
        page = int(request.GET.get('page', 1))
        
        # Search and filter parameters
        search = request.GET.get('search', '').strip()
        status_filter = request.GET.get('status', '').strip()
        customer_id = request.GET.get('customer_id', '').strip()
        payment_method = request.GET.get('payment_method', '').strip()
        date_from = request.GET.get('date_from', '').strip()
        date_to = request.GET.get('date_to', '').strip()
        
        # Base queryset
        if show_inactive:
            sales = Sales.objects.all()
        else:
            sales = Sales.objects.active()
        
        # Apply filters
        if search:
            sales = sales.search(search)
        
        if status_filter:
            sales = sales.by_status(status_filter)
        
        if customer_id:
            sales = sales.by_customer(customer_id)
        
        if payment_method:
            sales = sales.by_payment_method(payment_method)
        
        if date_from and date_to:
            sales = sales.by_date_range(date_from, date_to)
        
        # Pagination
        start = (page - 1) * page_size
        end = start + page_size
        total_count = sales.count()
        
        sales_page = sales[start:end]
        serializer = SalesListSerializer(sales_page, many=True)
        
        return Response({
            'success': True,
            'data': serializer.data,
            'pagination': {
                'page': page,
                'page_size': page_size,
                'total_count': total_count,
                'total_pages': (total_count + page_size - 1) // page_size
            }
        }, status=status.HTTP_200_OK)
        
    except Exception as e:
        return Response({
            'success': False,
            'message': 'Failed to list sales.',
            'errors': {'detail': str(e)}
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def create_sale(request):
    """Create a new sale"""
    serializer = SalesCreateSerializer(data=request.data)
    
    if serializer.is_valid():
        try:
            with transaction.atomic():
                sale = serializer.save(created_by=request.user)
                
                return Response({
                    'success': True,
                    'message': 'Sale created successfully.',
                    'data': SalesSerializer(sale).data
                }, status=status.HTTP_201_CREATED)
                
        except Exception as e:
            return Response({
                'success': False,
                'message': 'Failed to create sale.',
                'errors': {'detail': str(e)}
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    
    return Response({
        'success': False,
        'message': 'Sale creation failed.',
        'errors': serializer.errors
    }, status=status.HTTP_400_BAD_REQUEST)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_sale(request, sale_id):
    """Get sale details with items"""
    try:
        sale = Sales.objects.get(id=sale_id, is_active=True)
        serializer = SalesSerializer(sale)
        
        return Response({
            'success': True,
            'data': serializer.data
        }, status=status.HTTP_200_OK)
        
    except Sales.DoesNotExist:
        return Response({
            'success': False,
            'message': 'Sale not found.'
        }, status=status.HTTP_404_NOT_FOUND)
    except Exception as e:
        return Response({
            'success': False,
            'message': 'Failed to retrieve sale.',
            'errors': {'detail': str(e)}
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['PUT', 'PATCH'])
@permission_classes([IsAuthenticated])
def update_sale(request, sale_id):
    """Update sale details"""
    try:
        sale = Sales.objects.get(id=sale_id, is_active=True)
        
        if request.method == 'PUT':
            serializer = SalesUpdateSerializer(sale, data=request.data)
        else:
            serializer = SalesUpdateSerializer(sale, data=request.data, partial=True)
        
        if serializer.is_valid():
            with transaction.atomic():
                updated_sale = serializer.save()
                
                return Response({
                    'success': True,
                    'message': 'Sale updated successfully.',
                    'data': SalesSerializer(updated_sale).data
                }, status=status.HTTP_200_OK)
        
        return Response({
            'success': False,
            'message': 'Sale update failed.',
            'errors': serializer.errors
        }, status=status.HTTP_400_BAD_REQUEST)
        
    except Sales.DoesNotExist:
        return Response({
            'success': False,
            'message': 'Sale not found.'
        }, status=status.HTTP_404_NOT_FOUND)
    except Exception as e:
        return Response({
            'success': False,
            'message': 'Failed to update sale.',
            'errors': {'detail': str(e)}
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['DELETE'])
@permission_classes([IsAuthenticated])
def delete_sale(request, sale_id):
    """Soft delete sale"""
    try:
        sale = Sales.objects.get(id=sale_id, is_active=True)
        sale.is_active = False
        sale.save()
        
        return Response({
            'success': True,
            'message': 'Sale deleted successfully.'
        }, status=status.HTTP_200_OK)
        
    except Sales.DoesNotExist:
        return Response({
            'success': False,
            'message': 'Sale not found.'
        }, status=status.HTTP_404_NOT_FOUND)
    except Exception as e:
        return Response({
            'success': False,
            'message': 'Failed to delete sale.',
            'errors': {'detail': str(e)}
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def add_payment(request, sale_id):
    """Record payment for a sale"""
    try:
        sale = Sales.objects.get(id=sale_id, is_active=True)
        serializer = SalesPaymentSerializer(data=request.data)
        
        if serializer.is_valid():
            payment_data = serializer.validated_data
            
            with transaction.atomic():
                # Update payment details
                sale.payment_method = payment_data['payment_method']
                sale.amount_paid += payment_data['amount']
                
                if payment_data['payment_method'] == 'SPLIT':
                    sale.split_payment_details = payment_data.get('split_payment_details', {})
                
                sale.update_payment_status()
                sale.save()
                
                return Response({
                    'success': True,
                    'message': 'Payment recorded successfully.',
                    'data': SalesSerializer(sale).data
                }, status=status.HTTP_200_OK)
        
        return Response({
            'success': False,
            'message': 'Payment recording failed.',
            'errors': serializer.errors
        }, status=status.HTTP_400_BAD_REQUEST)
        
    except Sales.DoesNotExist:
        return Response({
            'success': False,
            'message': 'Sale not found.'
        }, status=status.HTTP_404_NOT_FOUND)
    except Exception as e:
        return Response({
            'success': False,
            'message': 'Failed to record payment.',
            'errors': {'detail': str(e)}
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def update_status(request, sale_id):
    """Update sale status"""
    try:
        sale = Sales.objects.get(id=sale_id, is_active=True)
        serializer = SalesStatusUpdateSerializer(data=request.data)
        
        if serializer.is_valid():
            new_status = serializer.validated_data['status']
            
            with transaction.atomic():
                sale.status = new_status
                sale.save()
                
                return Response({
                    'success': True,
                    'message': f'Sale status updated to {new_status}.',
                    'data': SalesSerializer(sale).data
                }, status=status.HTTP_200_OK)
        
        return Response({
            'success': False,
            'message': 'Status update failed.',
            'errors': serializer.errors
        }, status=status.HTTP_400_BAD_REQUEST)
        
    except Sales.DoesNotExist:
        return Response({
            'success': False,
            'message': 'Sale not found.'
        }, status=status.HTTP_404_NOT_FOUND)
    except Exception as e:
        return Response({
            'success': False,
            'message': 'Failed to update status.',
            'errors': {'detail': str(e)}
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def customer_sales_history(request, customer_id):
    """Get sales history for a specific customer"""
    try:
        customer = Customer.objects.get(id=customer_id, is_active=True)
        sales = Sales.objects.by_customer(customer_id).active()
        
        serializer = SalesListSerializer(sales, many=True)
        
        return Response({
            'success': True,
            'data': {
                'customer': {
                    'id': customer.id,
                    'name': customer.name,
                    'phone': customer.phone
                },
                'sales': serializer.data,
                'total_sales': sales.count(),
                'total_revenue': sales.aggregate(total=Sum('grand_total'))['total'] or Decimal('0.00')
            }
        }, status=status.HTTP_200_OK)
        
    except Customer.DoesNotExist:
        return Response({
            'success': False,
            'message': 'Customer not found.'
        }, status=status.HTTP_404_NOT_FOUND)
    except Exception as e:
        return Response({
            'success': False,
            'message': 'Failed to retrieve customer sales history.',
            'errors': {'detail': str(e)}
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def bulk_action_sales(request):
    """Perform bulk actions on sales"""
    serializer = SalesBulkActionSerializer(data=request.data)
    
    if serializer.is_valid():
        try:
            action = serializer.validated_data['action']
            sale_ids = serializer.validated_data['sale_ids']
            
            with transaction.atomic():
                sales = Sales.objects.filter(id__in=sale_ids, is_active=True)
                updated_count = 0
                
                if action == 'activate':
                    updated_count = sales.update(is_active=True)
                elif action == 'deactivate':
                    updated_count = sales.update(is_active=False)
                elif action == 'confirm':
                    updated_count = sales.filter(status='DRAFT').update(status='CONFIRMED')
                elif action == 'invoice':
                    updated_count = sales.filter(status='CONFIRMED').update(status='INVOICED')
                elif action == 'mark_paid':
                    updated_count = sales.filter(status='INVOICED').update(status='PAID')
                elif action == 'deliver':
                    updated_count = sales.filter(status='PAID').update(status='DELIVERED')
                elif action == 'cancel':
                    updated_count = sales.filter(status__in=['DRAFT', 'CONFIRMED', 'INVOICED']).update(status='CANCELLED')
                elif action == 'return':
                    updated_count = sales.filter(status='DELIVERED').update(status='RETURNED')
                elif action == 'recalculate':
                    for sale in sales:
                        sale.recalculate_totals()
                    updated_count = len(sales)
                
                return Response({
                    'success': True,
                    'message': f'Bulk action "{action}" completed successfully on {updated_count} sales.',
                    'updated_count': updated_count
                }, status=status.HTTP_200_OK)
                
        except Exception as e:
            return Response({
                'success': False,
                'message': 'Failed to perform bulk action.',
                'errors': {'detail': str(e)}
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    
    return Response({
        'success': False,
        'message': 'Bulk action failed.',
        'errors': serializer.errors
    }, status=status.HTTP_400_BAD_REQUEST)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def sales_statistics(request):
    """Get sales statistics and analytics"""
    try:
        # Get date range parameters
        days = int(request.GET.get('days', 30))
        
        # Calculate statistics
        recent_sales = Sales.objects.recent(days)
        total_sales = recent_sales.count()
        total_revenue = recent_sales.aggregate(total=Sum('grand_total'))['total'] or Decimal('0.00')
        total_items = recent_sales.aggregate(total=Sum('total_items'))['total'] or 0
        average_sale_value = total_revenue / total_sales if total_sales > 0 else Decimal('0.00')
        
        # Payment completion rate
        paid_sales = recent_sales.filter(is_fully_paid=True).count()
        payment_completion_rate = (paid_sales / total_sales * 100) if total_sales > 0 else 0
        
        # Top products
        top_products = SaleItem.objects.filter(
            sale__in=recent_sales
        ).values('product_name').annotate(
            total_quantity=Sum('quantity'),
            total_revenue=Sum('line_total')
        ).order_by('-total_revenue')[:10]
        
        # Top customers
        top_customers = recent_sales.values('customer_name').annotate(
            total_sales=Count('id'),
            total_revenue=Sum('grand_total')
        ).order_by('-total_revenue')[:10]
        
        # Monthly trends (simplified)
        monthly_trends = recent_sales.extra(
            select={'month': "EXTRACT(month FROM date_of_sale)"}
        ).values('month').annotate(
            sales_count=Count('id'),
            revenue=Sum('grand_total')
        ).order_by('month')
        
        data = {
            'total_sales': total_sales,
            'total_revenue': total_revenue,
            'total_items_sold': total_items,
            'average_sale_value': average_sale_value,
            'payment_completion_rate': payment_completion_rate,
            'top_products': list(top_products),
            'top_customers': list(top_customers),
            'monthly_trends': list(monthly_trends)
        }
        
        serializer = SalesStatisticsSerializer(data)
        
        return Response({
            'success': True,
            'data': serializer.data
        }, status=status.HTTP_200_OK)
        
    except Exception as e:
        return Response({
            'success': False,
            'message': 'Failed to retrieve sales statistics.',
            'errors': {'detail': str(e)}
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def create_from_order(request):
    """Create sale from existing order"""
    serializer = OrderToSaleConversionSerializer(data=request.data)
    
    if serializer.is_valid():
        try:
            with transaction.atomic():
                order_id = serializer.validated_data['order_id']
                order = Order.objects.get(id=order_id)
                
                # Create sale
                sale_data = {
                    'order_id': order,
                    'customer': order.customer,
                    'overall_discount': serializer.validated_data['overall_discount'],
                    'gst_percentage': serializer.validated_data['gst_percentage'],
                    'amount_paid': serializer.validated_data['amount_paid'],
                    'payment_method': serializer.validated_data['payment_method'],
                    'split_payment_details': serializer.validated_data.get('split_payment_details', {}),
                    'notes': serializer.validated_data.get('notes', ''),
                    'status': 'CONFIRMED',
                    'created_by': request.user
                }
                
                sale = Sales.objects.create(**sale_data)
                
                # Create sale items from order items
                partial_items = serializer.validated_data.get('partial_items', [])
                
                if partial_items:
                    # Partial conversion
                    for item_data in partial_items:
                        order_item_id = item_data.get('order_item_id')
                        quantity_to_sell = item_data.get('quantity_to_sell', 1)
                        
                        try:
                            order_item = OrderItem.objects.get(id=order_item_id, order=order)
                            
                            if quantity_to_sell <= order_item.quantity:
                                SaleItem.objects.create(
                                    sale=sale,
                                    order_item=order_item,
                                    product=order_item.product,
                                    unit_price=order_item.unit_price,
                                    quantity=quantity_to_sell,
                                    customization_notes=order_item.customization_notes
                                )
                        except OrderItem.DoesNotExist:
                            continue
                else:
                    # Full conversion
                    for order_item in order.order_items.all():
                        SaleItem.objects.create(
                            sale=sale,
                            order_item=order_item,
                            product=order_item.product,
                            unit_price=order_item.unit_price,
                            quantity=order_item.quantity,
                            customization_notes=order_item.customization_notes
                        )
                
                # Recalculate totals
                sale.recalculate_totals()
                
                return Response({
                    'success': True,
                    'message': 'Sale created from order successfully.',
                    'data': SalesSerializer(sale).data
                }, status=status.HTTP_201_CREATED)
                
        except Exception as e:
            return Response({
                'success': False,
                'message': 'Failed to create sale from order.',
                'errors': {'detail': str(e)}
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    
    return Response({
        'success': False,
        'message': 'Order to sale conversion failed.',
        'errors': serializer.errors
    }, status=status.HTTP_400_BAD_REQUEST)


# Sale Items views

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def list_sale_items(request):
    """List sale items with filtering"""
    try:
        sale_id = request.GET.get('sale_id', '').strip()
        product_id = request.GET.get('product_id', '').strip()
        
        sale_items = SaleItem.objects.active()
        
        if sale_id:
            sale_items = sale_items.by_sale(sale_id)
        
        if product_id:
            sale_items = sale_items.by_product(product_id)
        
        serializer = SaleItemListSerializer(sale_items, many=True)
        
        return Response({
            'success': True,
            'data': serializer.data
        }, status=status.HTTP_200_OK)
        
    except Exception as e:
        return Response({
            'success': False,
            'message': 'Failed to list sale items.',
            'errors': {'detail': str(e)}
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def create_sale_item(request):
    """Create a new sale item"""
    serializer = SaleItemCreateSerializer(data=request.data)
    
    if serializer.is_valid():
        try:
            with transaction.atomic():
                sale_item = serializer.save()
                
                # Recalculate sale totals
                sale_item.sale.recalculate_totals()
                
                return Response({
                    'success': True,
                    'message': 'Sale item created successfully.',
                    'data': SaleItemSerializer(sale_item).data
                }, status=status.HTTP_201_CREATED)
                
        except Exception as e:
            return Response({
                'success': False,
                'message': 'Failed to create sale item.',
                'errors': {'detail': str(e)}
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    
    return Response({
        'success': False,
        'message': 'Sale item creation failed.',
        'errors': serializer.errors
    }, status=status.HTTP_400_BAD_REQUEST)


@api_view(['PUT', 'PATCH'])
@permission_classes([IsAuthenticated])
def update_sale_item(request, item_id):
    """Update sale item"""
    try:
        sale_item = SaleItem.objects.get(id=item_id, is_active=True)
        
        if request.method == 'PUT':
            serializer = SaleItemUpdateSerializer(sale_item, data=request.data)
        else:
            serializer = SaleItemUpdateSerializer(sale_item, data=request.data, partial=True)
        
        if serializer.is_valid():
            with transaction.atomic():
                updated_item = serializer.save()
                
                # Recalculate sale totals
                updated_item.sale.recalculate_totals()
                
                return Response({
                    'success': True,
                    'message': 'Sale item updated successfully.',
                    'data': SaleItemSerializer(updated_item).data
                }, status=status.HTTP_200_OK)
        
        return Response({
            'success': False,
            'message': 'Sale item update failed.',
            'errors': serializer.errors
        }, status=status.HTTP_400_BAD_REQUEST)
        
    except SaleItem.DoesNotExist:
        return Response({
            'success': False,
            'message': 'Sale item not found.'
        }, status=status.HTTP_404_NOT_FOUND)
    except Exception as e:
        return Response({
            'success': False,
            'message': 'Failed to update sale item.',
            'errors': {'detail': str(e)}
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['DELETE'])
@permission_classes([IsAuthenticated])
def delete_sale_item(request, item_id):
    """Delete sale item"""
    try:
        sale_item = SaleItem.objects.get(id=item_id, is_active=True)
        
        with transaction.atomic():
            sale_item.is_active = False
            sale_item.save()
            
            # Recalculate sale totals
            sale_item.sale.recalculate_totals()
            
            return Response({
                'success': True,
                'message': 'Sale item deleted successfully.'
            }, status=status.HTTP_200_OK)
        
    except SaleItem.DoesNotExist:
        return Response({
            'success': False,
            'message': 'Sale item not found.'
        }, status=status.HTTP_404_NOT_FOUND)
    except Exception as e:
        return Response({
            'success': False,
            'message': 'Failed to delete sale item.',
            'errors': {'detail': str(e)}
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

# ===== INVOICE MANAGEMENT =====

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def create_invoice(request):
    """Create a new invoice for a sale"""
    serializer = InvoiceCreateSerializer(data=request.data, context={'request': request})
    
    if serializer.is_valid():
        try:
            with transaction.atomic():
                invoice = serializer.save()
                
                # Update sale status to INVOICED if it's not already
                sale = invoice.sale
                if sale.status == 'CONFIRMED':
                    sale.status = 'INVOICED'
                    sale.save(update_fields=['status', 'updated_at'])
                
                return Response({
                    'success': True,
                    'message': 'Invoice created successfully',
                    'data': InvoiceSerializer(invoice).data
                }, status=status.HTTP_201_CREATED)
        except Exception as e:
            return Response({
                'success': False,
                'message': 'Failed to create invoice',
                'errors': {'detail': str(e)}
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    
    return Response({
        'success': False,
        'message': 'Invalid invoice data',
        'errors': serializer.errors
    }, status=status.HTTP_400_BAD_REQUEST)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_invoice(request, invoice_id):
    """Get invoice details"""
    try:
        invoice = Invoice.objects.get(id=invoice_id, is_active=True)
        serializer = InvoiceSerializer(invoice)
        
        return Response({
            'success': True,
            'data': serializer.data
        }, status=status.HTTP_200_OK)
    except Exception as e:
        return Response({
            'success': False,
            'message': 'Failed to get invoice',
            'errors': {'detail': str(e)}
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['PUT'])
@permission_classes([IsAuthenticated])
def update_invoice(request, invoice_id):
    """Update invoice details"""
    try:
        invoice = Invoice.objects.get(id=invoice_id, is_active=True)
        serializer = InvoiceUpdateSerializer(invoice, data=request.data, partial=True)
        
        if serializer.is_valid():
            invoice = serializer.save()
            return Response({
                'success': True,
                'message': 'Invoice updated successfully',
                'data': InvoiceSerializer(invoice).data
            }, status=status.HTTP_200_OK)
        
        return Response({
            'success': False,
            'message': 'Invalid invoice data',
            'errors': serializer.errors
        }, status=status.HTTP_400_BAD_REQUEST)
    except Exception as e:
        return Response({
            'success': False,
            'message': 'Failed to update invoice',
            'errors': {'detail': str(e)}
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def list_invoices(request):
    """List all invoices with filtering and pagination"""
    try:
        # Get query parameters
        show_inactive = request.GET.get('show_inactive', 'false').lower() == 'true'
        page_size = min(int(request.GET.get('page_size', 20)), 100)
        page = int(request.GET.get('page', 1))
        
        # Filter parameters
        status_filter = request.GET.get('status', '').strip()
        customer_id = request.GET.get('customer_id', '').strip()
        date_from = request.GET.get('date_from', '').strip()
        date_to = request.GET.get('date_to', '').strip()
        overdue_only = request.GET.get('overdue_only', 'false').lower() == 'true'
        
        # Base queryset
        if show_inactive:
            invoices = Invoice.objects.all()
        else:
            invoices = Invoice.objects.filter(is_active=True)
        
        # Apply filters
        if status_filter:
            invoices = invoices.filter(status=status_filter.upper())
        
        if customer_id:
            invoices = invoices.filter(sale__customer_id=customer_id)
        
        if date_from and date_to:
            invoices = invoices.filter(issue_date__date__range=[date_from, date_to])
        
        if overdue_only:
            invoices = invoices.filter(due_date__lt=timezone.now().date(), status__in=['DRAFT', 'ISSUED', 'SENT'])
        
        # Pagination
        start = (page - 1) * page_size
        end = start + page_size
        total_count = invoices.count()
        
        invoices_page = invoices[start:end]
        serializer = InvoiceListSerializer(invoices_page, many=True)
        
        return Response({
            'success': True,
            'data': serializer.data,
            'pagination': {
                'page': page,
                'page_size': page_size,
                'total_count': total_count,
                'total_pages': (total_count + page_size - 1) // page_size
            }
        }, status=status.HTTP_200_OK)
    except Exception as e:
        return Response({
            'success': False,
            'message': 'Failed to list invoices',
            'errors': {'detail': str(e)}
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def generate_invoice_pdf(request, invoice_id):
    """Generate PDF for invoice"""
    try:
        from reportlab.lib.pagesizes import letter, A4
        from reportlab.platypus import SimpleDocTemplate, Table, TableStyle, Paragraph, Spacer
        from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
        from reportlab.lib.units import inch
        from reportlab.lib import colors
        from reportlab.pdfgen import canvas
        from django.conf import settings
        import os
        from io import BytesIO
        
        invoice = get_object_or_404(Invoice, id=invoice_id, is_active=True)
        
        # Create PDF buffer
        buffer = BytesIO()
        
        # Create PDF document
        doc = SimpleDocTemplate(buffer, pagesize=A4)
        story = []
        
        # Get styles
        styles = getSampleStyleSheet()
        title_style = ParagraphStyle(
            'CustomTitle',
            parent=styles['Heading1'],
            fontSize=18,
            spaceAfter=30,
            alignment=1,  # Center alignment
        )
        
        # Add title
        story.append(Paragraph(f"INVOICE #{invoice.invoice_number}", title_style))
        story.append(Spacer(1, 20))
        
        # Company and customer info
        company_info = [
            ['Company: Maqbool Fabric', f'Invoice Date: {invoice.issue_date.strftime("%B %d, %Y")}'],
            ['Address: Your Company Address', f'Due Date: {invoice.due_date.strftime("%B %d, %Y")}'],
            ['Phone: +92-XXX-XXXXXXX', f'Status: {invoice.status}'],
        ]
        
        company_table = Table(company_info, colWidths=[3*inch, 3*inch])
        company_table.setStyle(TableStyle([
            ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
            ('FONTNAME', (0, 0), (-1, -1), 'Helvetica'),
            ('FONTSIZE', 10),
            ('BOTTOMPADDING', 6, 6, 6),
        ]))
        story.append(company_table)
        story.append(Spacer(1, 20))
        
        # Customer details
        if invoice.sale and invoice.sale.customer:
            customer = invoice.sale.customer
            customer_info = [
                ['Customer Information:'],
                ['Name:', customer.name],
                ['Phone:', customer.phone or 'N/A'],
                ['Email:', customer.email or 'N/A'],
                ['Address:', customer.address or 'N/A'],
            ]
            
            customer_table = Table(customer_info, colWidths=[1.5*inch, 4.5*inch])
            customer_table.setStyle(TableStyle([
                ('ALIGN', (0, 0), (0, -1), 'LEFT'),
                ('ALIGN', (1, 0), (1, -1), 'LEFT'),
                ('FONTNAME', (0, 0), (-1, -1), 'Helvetica'),
                ('FONTSIZE', 10),
                ('BOTTOMPADDING', 6, 6, 6),
                ('BACKGROUND', (0, 0), (0, 0), colors.grey),
                ('TEXTCOLOR', (0, 0), (0, 0), colors.whitesmoke),
            ]))
            story.append(customer_table)
            story.append(Spacer(1, 20))
        
        # Invoice items
        if invoice.sale and invoice.sale.sale_items.exists():
            items_data = [['Item', 'Description', 'Qty', 'Unit Price', 'Total']]
            
            for item in invoice.sale.sale_items.all():
                items_data.append([
                    item.product.name if item.product else 'N/A',
                    item.product.description[:50] + '...' if item.product and item.product.description and len(item.product.description) > 50 else (item.product.description if item.product else 'N/A'),
                    str(item.quantity),
                    f"PKR {item.unit_price:.2f}",
                    f"PKR {(item.quantity * item.unit_price):.2f}",
                ])
            
            items_table = Table(items_data, colWidths=[1.5*inch, 2*inch, 0.8*inch, 1.2*inch, 1.2*inch])
            items_table.setStyle(TableStyle([
                ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
                ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
                ('FONTSIZE', 10),
                ('BOTTOMPADDING', 6, 6, 6),
                ('BACKGROUND', (0, 0), (-1, 0), colors.grey),
                ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),
                ('GRID', (0, 0), (-1, -1), 1, colors.black),
            ]))
            story.append(items_table)
            story.append(Spacer(1, 20))
        
        # Totals
        totals_data = [
            ['Subtotal:', f"PKR {invoice.sale.subtotal:.2f}" if invoice.sale else 'PKR 0.00'],
            ['Tax:', f"PKR {invoice.sale.taxAmount:.2f}" if invoice.sale else 'PKR 0.00'],
            ['Discount:', f"PKR {invoice.sale.discountAmount:.2f}" if invoice.sale else 'PKR 0.00'],
            ['Total:', f"PKR {invoice.sale.grandTotal:.2f}" if invoice.sale else 'PKR 0.00'],
        ]
        
        totals_table = Table(totals_data, colWidths=[1*inch, 1*inch])
        totals_table.setStyle(TableStyle([
            ('ALIGN', (0, 0), (0, -1), 'RIGHT'),
            ('ALIGN', (1, 0), (1, -1), 'RIGHT'),
            ('FONTNAME', (0, 0), (-1, -1), 'Helvetica'),
            ('FONTSIZE', 10),
            ('BOTTOMPADDING', 6, 6, 6),
            ('FONTNAME', (0, -1), (1, -1), 'Helvetica-Bold'),
            ('FONTSIZE', (0, -1), (1, -1), 12),
        ]))
        story.append(totals_table)
        
        # Build PDF
        doc.build(story)
        
        # Get PDF content
        pdf_content = buffer.getvalue()
        buffer.close()
        
        # Save PDF to file
        filename = f"invoice_{invoice.invoice_number}_{invoice.issue_date.strftime('%Y%m%d')}.pdf"
        filepath = os.path.join(settings.MEDIA_ROOT, 'invoices', filename)
        
        # Ensure directory exists
        os.makedirs(os.path.dirname(filepath), exist_ok=True)
        
        with open(filepath, 'wb') as f:
            f.write(pdf_content)
        
        # Update invoice with PDF file
        from django.core.files.base import ContentFile
        invoice.pdf_file.save(filename, ContentFile(pdf_content), save=True)
        invoice.status = 'ISSUED'
        invoice.save(update_fields=['status', 'updated_at', 'pdf_file'])
        
        return Response({
            'success': True,
            'message': 'Invoice PDF generated successfully',
            'data': {
                'invoice_id': str(invoice.id),
                'status': invoice.status,
                'pdf_url': invoice.pdf_file.url if invoice.pdf_file else None,
                'filename': filename
            }
        }, status=status.HTTP_200_OK)
        
    except Exception as e:
        return Response({
            'success': False,
            'message': 'Failed to generate invoice PDF',
            'errors': {'detail': str(e)}
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


# ===== RECEIPT MANAGEMENT =====

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def create_receipt(request):
    """Create a new receipt for a payment"""
    serializer = ReceiptCreateSerializer(data=request.data, context={'request': request})
    
    if serializer.is_valid():
        try:
            with transaction.atomic():
                receipt = serializer.save()
                
                return Response({
                    'success': True,
                    'message': 'Receipt created successfully',
                    'data': ReceiptSerializer(receipt).data
                }, status=status.HTTP_201_CREATED)
        except Exception as e:
            return Response({
                'success': False,
                'message': 'Failed to create receipt',
                'errors': {'detail': str(e)}
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    
    return Response({
        'success': False,
        'message': 'Invalid receipt data',
        'errors': serializer.errors
    }, status=status.HTTP_400_BAD_REQUEST)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_receipt(request, receipt_id):
    """Get receipt details"""
    try:
        receipt = get_object_or_404(Receipt, id=receipt_id, is_active=True)
        serializer = ReceiptSerializer(receipt)
        
        return Response({
            'success': True,
            'data': serializer.data
        }, status=status.HTTP_200_OK)
    except Exception as e:
        return Response({
            'success': False,
            'message': 'Failed to get receipt',
            'errors': {'detail': str(e)}
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['PUT'])
@permission_classes([IsAuthenticated])
def update_receipt(request, receipt_id):
    """Update receipt details"""
    try:
        receipt = get_object_or_404(Receipt, id=receipt_id, is_active=True)
        serializer = ReceiptUpdateSerializer(receipt, data=request.data, partial=True)
        
        if serializer.is_valid():
            receipt = serializer.save()
            return Response({
                'success': True,
                'message': 'Receipt updated successfully',
                'data': ReceiptSerializer(receipt).data
            }, status=status.HTTP_200_OK)
        
        return Response({
            'success': False,
            'message': 'Invalid receipt data',
            'errors': serializer.errors
        }, status=status.HTTP_400_BAD_REQUEST)
    except Exception as e:
        return Response({
            'success': False,
            'message': 'Failed to update receipt',
            'errors': {'detail': str(e)}
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def list_receipts(request):
    """List all receipts with filtering and pagination"""
    try:
        # Get query parameters
        show_inactive = request.GET.get('show_inactive', 'false').lower() == 'true'
        page_size = min(int(request.GET.get('page_size', 20)), 100)
        page = int(request.GET.get('page', 1))
        
        # Filter parameters
        sale_id = request.GET.get('sale_id', '').strip()
        payment_id = request.GET.get('payment_id', '').strip()
        status_filter = request.GET.get('status', '').strip()
        date_from = request.GET.get('date_from', '').strip()
        date_to = request.GET.get('date_to', '').strip()
        
        # Base queryset
        if show_inactive:
            receipts = Receipt.objects.all()
        else:
            receipts = Receipt.objects.filter(is_active=True)
        
        # Apply filters
        if sale_id:
            receipts = receipts.filter(sale_id=sale_id)
        
        if payment_id:
            receipts = receipts.filter(payment_id=payment_id)
        
        if status_filter:
            receipts = receipts.filter(status=status_filter.upper())
        
        if date_from and date_to:
            receipts = receipts.filter(generated_at__date__range=[date_from, date_to])
        
        # Pagination
        start = (page - 1) * page_size
        end = start + page_size
        total_count = receipts.count()
        
        receipts_page = receipts[start:end]
        serializer = ReceiptListSerializer(receipts_page, many=True)
        
        return Response({
            'success': True,
            'data': serializer.data,
            'pagination': {
                'page': page,
                'page_size': page_size,
                'total_count': total_count,
                'total_pages': (total_count + page_size - 1) // page_size
            }
        }, status=status.HTTP_200_OK)
    except Exception as e:
        return Response({
            'success': False,
            'message': 'Failed to list receipts',
            'errors': {'detail': str(e)}
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def generate_receipt_pdf(request, receipt_id):
    """Generate PDF for receipt"""
    try:
        from reportlab.lib.pagesizes import letter, A4
        from reportlab.platypus import SimpleDocTemplate, Table, TableStyle, Paragraph, Spacer
        from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
        from reportlab.lib.units import inch
        from reportlab.lib import colors
        from reportlab.pdfgen import canvas
        from django.conf import settings
        import os
        from io import BytesIO
        
        receipt = get_object_or_404(Receipt, id=receipt_id, is_active=True)
        
        # Create PDF buffer
        buffer = BytesIO()
        
        # Create PDF document
        doc = SimpleDocTemplate(buffer, pagesize=A4)
        story = []
        
        # Get styles
        styles = getSampleStyleSheet()
        title_style = ParagraphStyle(
            'CustomTitle',
            parent=styles['Heading1'],
            fontSize=18,
            spaceAfter=30,
            alignment=1,  # Center alignment
        )
        
        # Add title
        story.append(Paragraph(f"RECEIPT #{receipt.receipt_number}", title_style))
        story.append(Spacer(1, 20))
        
        # Company and receipt info
        company_info = [
            ['Company: Maqbool Fabric', f'Receipt Date: {receipt.generated_at.strftime("%B %d, %Y")}'],
            ['Address: Your Company Address', f'Time: {receipt.generated_at.strftime("%I:%M %p")}'],
            ['Phone: +92-XXX-XXXXXXX', f'Status: {receipt.status}'],
        ]
        
        company_table = Table(company_info, colWidths=[3*inch, 3*inch])
        company_table.setStyle(TableStyle([
            ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
            ('FONTNAME', (0, 0), (-1, -1), 'Helvetica'),
            ('FONTSIZE', 10),
            ('BOTTOMPADDING', 6, 6, 6),
        ]))
        story.append(company_table)
        story.append(Spacer(1, 20))
        
        # Payment details
        if receipt.payment:
            payment = receipt.payment
            payment_info = [
                ['Payment Information:'],
                ['Payment ID:', payment.id],
                ['Payment Method:', payment.payment_method],
                ['Amount:', f"PKR {payment.amount:.2f}"],
                ['Status:', payment.status],
            ]
            
            payment_table = Table(payment_info, colWidths=[1.5*inch, 4.5*inch])
            payment_table.setStyle(TableStyle([
                ('ALIGN', (0, 0), (0, -1), 'LEFT'),
                ('ALIGN', (1, 0), (1, -1), 'LEFT'),
                ('FONTNAME', (0, 0), (-1, -1), 'Helvetica'),
                ('FONTSIZE', 10),
                ('BOTTOMPADDING', 6, 6, 6),
                ('BACKGROUND', (0, 0), (0, 0), colors.grey),
                ('TEXTCOLOR', (0, 0), (0, 0), colors.whitesmoke),
            ]))
            story.append(payment_table)
            story.append(Spacer(1, 20))
        
        # Sale details
        if receipt.sale:
            sale = receipt.sale
            if sale.customer:
                customer = sale.customer
                customer_info = [
                    ['Customer Information:'],
                    ['Name:', customer.name],
                    ['Phone:', customer.phone or 'N/A'],
                    ['Email:', customer.email or 'N/A'],
                ]
                
                customer_table = Table(customer_info, colWidths=[1.5*inch, 4.5*inch])
                customer_table.setStyle(TableStyle([
                    ('ALIGN', (0, 0), (0, -1), 'LEFT'),
                    ('ALIGN', (1, 0), (1, -1), 'LEFT'),
                    ('FONTNAME', (0, 0), (-1, -1), 'Helvetica'),
                    ('FONTSIZE', 10),
                    ('BOTTOMPADDING', 6, 6, 6),
                    ('BACKGROUND', (0, 0), (0, 0), colors.grey),
                    ('TEXTCOLOR', (0, 0), (0, 0), colors.whitesmoke),
                ]))
                story.append(customer_table)
                story.append(Spacer(1, 20))
        
        # Receipt summary
        summary_data = [
            ['Receipt Summary:'],
            ['Total Amount:', f"PKR {receipt.amount:.2f}"],
            ['Payment Method:', receipt.payment.payment_method if receipt.payment else 'N/A'],
            ['Transaction Date:', receipt.generated_at.strftime("%B %d, %Y at %I:%M %p")],
        ]
        
        summary_table = Table(summary_data, colWidths=[1.5*inch, 4.5*inch])
        summary_table.setStyle(TableStyle([
            ('ALIGN', (0, 0), (0, -1), 'LEFT'),
            ('ALIGN', (1, 0), (1, -1), 'LEFT'),
            ('FONTNAME', (0, 0), (-1, -1), 'Helvetica'),
            ('FONTSIZE', 10),
            ('BOTTOMPADDING', 6, 6, 6),
            ('BACKGROUND', (0, 0), (0, 0), colors.grey),
            ('TEXTCOLOR', (0, 0), (0, 0), colors.whitesmoke),
        ]))
        story.append(summary_table)
        
        # Build PDF
        doc.build(story)
        
        # Get PDF content
        pdf_content = buffer.getvalue()
        buffer.close()
        
        # Save PDF to file
        filename = f"receipt_{receipt.receipt_number}_{receipt.generated_at.strftime('%Y%m%d_%H%M')}.pdf"
        filepath = os.path.join(settings.MEDIA_ROOT, 'receipts', filename)
        
        # Ensure directory exists
        os.makedirs(os.path.dirname(filepath), exist_ok=True)
        
        with open(filepath, 'wb') as f:
            f.write(pdf_content)
        
        # Update receipt with PDF file
        from django.core.files.base import ContentFile
        receipt.pdf_file.save(filename, ContentFile(pdf_content), save=True)
        receipt.status = 'GENERATED'
        receipt.save(update_fields=['status', 'updated_at', 'pdf_file'])
        
        return Response({
            'success': True,
            'message': 'Receipt PDF generated successfully',
            'data': {
                'receipt_id': str(receipt.id),
                'status': receipt.status,
                'pdf_url': receipt.pdf_file.url if receipt.pdf_file else None,
                'filename': filename
            }
        }, status=status.HTTP_200_OK)
        
    except Exception as e:
        return Response({
            'success': False,
            'message': 'Failed to generate receipt PDF',
            'errors': {'detail': str(e)}
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
