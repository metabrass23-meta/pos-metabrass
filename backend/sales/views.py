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
from orders.models import Order, OrderItem


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
        sale = get_object_or_404(Sales, id=sale_id, is_active=True)
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
        sale = get_object_or_404(Sales, id=sale_id, is_active=True)
        
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
        sale = get_object_or_404(Sales, id=sale_id, is_active=True)
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
        sale = get_object_or_404(Sales, id=sale_id, is_active=True)
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
        sale = get_object_or_404(Sales, id=sale_id, is_active=True)
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
        customer = get_object_or_404(Customer, id=customer_id, is_active=True)
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
        sale_item = get_object_or_404(SaleItem, id=item_id, is_active=True)
        
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
        sale_item = get_object_or_404(SaleItem, id=item_id, is_active=True)
        
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
