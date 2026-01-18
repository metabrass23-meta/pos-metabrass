from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.utils import timezone
from django.db.models import Sum, Count, Avg, Q
from datetime import datetime, timedelta, date
from decimal import Decimal

# Import your models
from sales.models import Sale, SaleItem
from orders.models import Order
from customers.models import Customer
from products.models import Product
from vendors.models import Vendor
from expenses.models import Expense
from payments.models import Payment


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def dashboard_analytics(request):
    """Get comprehensive dashboard analytics with real data"""
    try:
        # Get current date and calculate date ranges
        today = timezone.now().date()
        last_week = today - timedelta(days=7)
        last_month = today - timedelta(days=30)
        
        # Calculate sales metrics
        total_sales = Sale.objects.filter(is_deleted=False).aggregate(
            total=Sum('total_amount'),
            count=Count('id')
        )
        
        # Calculate this month's sales
        this_month_sales = Sale.objects.filter(
            is_deleted=False,
            sale_date__gte=today.replace(day=1)
        ).aggregate(
            total=Sum('total_amount'),
            count=Count('id')
        )
        
        # Calculate orders metrics
        total_orders = Order.objects.filter(is_deleted=False).count()
        pending_orders = Order.objects.filter(
            is_deleted=False,
            status='PENDING'
        ).count()
        
        # Calculate customer metrics
        total_customers = Customer.objects.filter(is_deleted=False).count()
        active_customers = Customer.objects.filter(
            is_deleted=False,
            is_active=True
        ).count()
        
        # Calculate vendor metrics
        total_vendors = Vendor.objects.filter(is_deleted=False).count()
        active_vendors = Vendor.objects.filter(
            is_deleted=False,
            is_active=True
        ).count()
        
        # Calculate product metrics
        total_products = Product.objects.filter(is_deleted=False).count()
        low_stock_products = Product.objects.filter(
            is_deleted=False,
            quantity__lte=10
        ).count()
        
        # Calculate financial metrics
        total_expenses = Expense.objects.filter(is_deleted=False).aggregate(
            total=Sum('amount')
        )['total'] or Decimal('0.00')
        
        total_revenue = total_sales['total'] or Decimal('0.00')
        net_profit = total_revenue - total_expenses
        
        # Calculate recent activity counts
        recent_sales = Sale.objects.filter(
            is_deleted=False,
            sale_date__gte=last_week
        ).count()
        
        recent_orders = Order.objects.filter(
            is_deleted=False,
            order_date__gte=last_week
        ).count()
        
        # Get top selling products (last 30 days)
        top_products = SaleItem.objects.filter(
            is_deleted=False,
            sale__sale_date__gte=last_month,
            sale__is_deleted=False
        ).values('product__name').annotate(
            total_quantity=Sum('quantity'),
            total_revenue=Sum('total_price')
        ).order_by('-total_quantity')[:5]
        
        # Get sales trend (last 6 months)
        sales_trend = []
        for i in range(6, 0, -1):
            month_start = (today.replace(day=1) - timedelta(days=30*i))
            month_end = month_start + timedelta(days=30)
            
            month_sales = Sale.objects.filter(
                is_deleted=False,
                sale_date__gte=month_start,
                sale_date__lt=month_end
            ).aggregate(total=Sum('total_amount'))['total'] or Decimal('0.00')
            
            sales_trend.append({
                'month': month_start.strftime('%B'),
                'sales': float(month_sales)
            })
        
        # Get recent transactions
        recent_transactions = []
        recent_sales_list = Sale.objects.filter(
            is_deleted=False
        ).select_related('customer').order_by('-sale_date')[:10]
        
        for sale in recent_sales_list:
            recent_transactions.append({
                'id': str(sale.id),
                'type': 'SALE',
                'customer': sale.customer.name if sale.customer else 'Walk-in Customer',
                'amount': float(sale.total_amount),
                'date': sale.sale_date.isoformat(),
                'status': sale.payment_status
            })
        
        # Compile comprehensive analytics data
        analytics_data = {
            # Overview metrics
            'total_sales': float(total_revenue),
            'total_sales_count': total_sales['count'] or 0,
            'total_orders': total_orders,
            'pending_orders': pending_orders,
            'total_customers': total_customers,
            'active_customers': active_customers,
            'total_vendors': total_vendors,
            'active_vendors': active_vendors,
            'total_products': total_products,
            'low_stock_products': low_stock_products,
            
            # Financial metrics
            'total_revenue': float(total_revenue),
            'total_expenses': float(total_expenses),
            'net_profit': float(net_profit),
            'profit_margin': float((net_profit / total_revenue * 100) if total_revenue > 0 else 0),
            
            # This month metrics
            'this_month_sales': float(this_month_sales['total'] or Decimal('0.00')),
            'this_month_sales_count': this_month_sales['count'] or 0,
            
            # Recent activity
            'recent_sales_count': recent_sales,
            'recent_orders_count': recent_orders,
            
            # Top products
            'top_selling_products': [
                {
                    'name': product['product__name'],
                    'quantity': product['total_quantity'],
                    'revenue': float(product['total_revenue'] or 0)
                }
                for product in top_products
            ],
            
            # Sales trend
            'sales_trend': sales_trend,
            
            # Recent transactions
            'recent_transactions': recent_transactions,
            
            # Date ranges
            'date_ranges': {
                'today': today.isoformat(),
                'last_week': last_week.isoformat(),
                'last_month': last_month.isoformat(),
            }
        }
        
        return Response({
            'success': True,
            'data': analytics_data
        }, status=status.HTTP_200_OK)
        
    except Exception as e:
        import traceback
        print(f"Dashboard analytics error: {str(e)}")
        print(traceback.format_exc())
        
        return Response({
            'success': False,
            'message': 'Failed to get dashboard analytics.',
            'errors': {'detail': str(e)}
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def business_metrics(request):
    """Get business metrics list"""
    try:
        from .models import BusinessMetrics
        from .serializers import BusinessMetricSerializer
        
        metrics = BusinessMetrics.objects.all().order_by('-start_date')[:20]
        serializer = BusinessMetricSerializer(metrics, many=True)
        
        return Response({
            'success': True,
            'data': {
                'metrics': serializer.data,
                'pagination': {
                    'page': 1,
                    'page_size': 20,
                    'total_count': BusinessMetrics.objects.count(),
                    'total_pages': 1,
                    'has_next': False,
                    'has_previous': False
                }
            }
        }, status=status.HTTP_200_OK)
        
    except Exception as e:
        return Response({
            'success': False,
            'message': 'Failed to get business metrics.',
            'errors': {'detail': str(e)}
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def realtime_analytics(request):
    """Get real-time analytics data"""
    try:
        now = timezone.now()
        today = now.date()
        
        # Today's sales
        today_sales = Sale.objects.filter(
            is_deleted=False,
            sale_date=today
        ).aggregate(
            total=Sum('total_amount'),
            count=Count('id')
        )
        
        # Today's orders
        today_orders = Order.objects.filter(
            is_deleted=False,
            order_date=today
        ).count()
        
        # Active sessions (customers who made purchases in last hour)
        one_hour_ago = now - timedelta(hours=1)
        active_sessions = Sale.objects.filter(
            is_deleted=False,
            created_at__gte=one_hour_ago
        ).values('customer').distinct().count()
        
        realtime_data = {
            'current_time': now.isoformat(),
            'today_date': today.isoformat(),
            'today_sales': float(today_sales['total'] or Decimal('0.00')),
            'today_sales_count': today_sales['count'] or 0,
            'today_orders': today_orders,
            'active_sessions': active_sessions,
            'pending_orders': Order.objects.filter(
                is_deleted=False,
                status='PENDING'
            ).count(),
        }
        
        return Response({
            'success': True,
            'data': realtime_data
        }, status=status.HTTP_200_OK)
        
    except Exception as e:
        return Response({
            'success': False,
            'message': 'Failed to get real-time analytics.',
            'errors': {'detail': str(e)}
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)