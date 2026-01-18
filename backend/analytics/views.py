"""
CORRECTED Dashboard Analytics View
File: backend/analytics/views.py

IMPORTANT: This version uses the correct model names:
- Sales (not Sale)
- SaleItem (not SaleItem) - this one was correct
"""

from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.utils import timezone
from django.db.models import Sum, Count, Avg, Q, F
from datetime import datetime, timedelta
from decimal import Decimal

# Import your models - CORRECTED IMPORTS
from sales.models import Sales, SaleItem  # ← Changed from 'Sale' to 'Sales'
from orders.models import Order
from customers.models import Customer
from products.models import Product
from vendors.models import Vendor
from expenses.models import Expense
from payments.models import Payment
from rest_framework.throttling import UserRateThrottle

class DashboardRateThrottle(UserRateThrottle):
    scope = 'dashboard'

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def dashboard_analytics(request):
    """
    Get comprehensive dashboard analytics with ALL required metrics
    """
    try:
        # Get current date and calculate date ranges
        today = timezone.now().date()
        last_week = today - timedelta(days=7)
        last_month = today - timedelta(days=30)
        current_month_start = today.replace(day=1)
        
        # =====================================================
        # SALES METRICS
        # =====================================================
        
        # Total sales (all time) - Using 'Sales' model
        total_sales_data = Sales.objects.filter(is_active=True).aggregate(
            total=Sum('grand_total'),
            count=Count('id')
        )
        total_sales = total_sales_data['total'] or Decimal('0.00')
        total_sales_count = total_sales_data['count'] or 0
        
        # This month's sales
        this_month_sales_data = Sales.objects.filter(
            is_active=True,
            date_of_sale__gte=current_month_start
        ).aggregate(
            total=Sum('grand_total'),
            count=Count('id')
        )
        this_month_sales = this_month_sales_data['total'] or Decimal('0.00')
        this_month_sales_count = this_month_sales_data['count'] or 0
        
        # Recent sales (last 7 days)
        recent_sales_count = Sales.objects.filter(
            is_active=True,
            date_of_sale__gte=last_week
        ).count()
        
        # =====================================================
        # ORDER METRICS ⭐ NEW
        # =====================================================
        
        # Total orders (all active orders)
        total_orders = Order.objects.filter(is_active=True).count()
        
        # Pending orders
        pending_orders = Order.objects.filter(
            is_active=True,
            status='PENDING'
        ).count()
        
        # Recent orders (last 7 days)
        recent_orders_count = Order.objects.filter(
            is_active=True,
            created_at__gte=last_week
        ).count()
        
        # =====================================================
        # CUSTOMER METRICS ⭐ NEW
        # =====================================================
        
        # Total active customers
        total_customers = Customer.objects.filter(is_active=True).count()
        
        # Active customers (customers who made purchases in last 30 days)
        active_customers = Customer.objects.filter(
            is_active=True,
            sales__date_of_sale__gte=last_month,
            sales__is_active=True
        ).distinct().count()
        
        # =====================================================
        # VENDOR METRICS ⭐ NEW
        # =====================================================
        
        # Total active vendors
        total_vendors = Vendor.objects.filter(is_active=True).count()
        
        # Active vendors (vendors with payments in last 30 days)
        # Note: Adjust the related_name based on your Payment model's ForeignKey to Vendor
        try:
            active_vendors = Vendor.objects.filter(
                is_active=True,
                payments__created_at__gte=last_month  # May need to adjust related_name
            ).distinct().count()
        except:
            # Fallback: count vendors updated recently
            active_vendors = Vendor.objects.filter(
                is_active=True,
                updated_at__gte=last_month
            ).count()
        
        # =====================================================
        # PRODUCT METRICS ⭐ NEW
        # =====================================================
        
        # Total active products
        total_products = Product.objects.filter(is_active=True).count()
        
        # Low stock products
        # Try using reorder_point if it exists, otherwise use threshold of 10
        try:
            low_stock_products = Product.objects.filter(
                is_active=True,
                quantity__lt=F('reorder_point')
            ).count()
        except Exception as e:
            # Fallback: use arbitrary threshold (quantity < 10)
            low_stock_products = Product.objects.filter(
                is_active=True,
                quantity__lt=10
            ).count()
        
        # =====================================================
        # FINANCIAL METRICS
        # =====================================================
        
        # Calculate total revenue (same as total sales for now)
        total_revenue = total_sales
        
        # Calculate total expenses
        # Sum from expenses table
        expenses_total = Expense.objects.filter(
            is_active=True
        ).aggregate(total=Sum('amount'))['total'] or Decimal('0.00')
        
        # Add labor payments
        labor_payments = Payment.objects.filter(
            payer_type='LABOR'
        ).aggregate(total=Sum('amount_paid'))['total'] or Decimal('0.00')
        
        # Add vendor payments
        vendor_payments = Payment.objects.filter(
            payer_type='VENDOR'
        ).aggregate(total=Sum('amount_paid'))['total'] or Decimal('0.00')
        
        # Total expenses
        total_expenses = expenses_total + labor_payments + vendor_payments
        
        # Net profit = Revenue - Expenses
        net_profit = total_revenue - total_expenses
        
        # Profit margin = (Net profit / Revenue) * 100
        profit_margin = (net_profit / total_revenue * 100) if total_revenue > 0 else 0
        
        # =====================================================
        # TOP SELLING PRODUCTS
        # =====================================================
        
        top_products = SaleItem.objects.filter(
            sale__is_active=True,
            sale__date_of_sale__gte=last_month
        ).values('product__name').annotate(
            total_quantity=Sum('quantity'),
            total_revenue=Sum('line_total')
        ).order_by('-total_revenue')[:10]
        
        # Format top products for response
        top_selling_products = [
            {
                'name': product['product__name'],
                'quantity': product['total_quantity'],
                'revenue': float(product['total_revenue'] or 0)
            }
            for product in top_products
        ]
        
        # =====================================================
        # SALES TREND (Last 6 months)
        # =====================================================
        
        # Get sales grouped by month for last 6 months
        six_months_ago = today - timedelta(days=180)
        
        # Use PostgreSQL-specific date formatting
        monthly_sales = Sales.objects.filter(
            is_active=True,
            date_of_sale__gte=six_months_ago
        ).extra(
            select={'month': "TO_CHAR(date_of_sale, 'Mon')"}
        ).values('month').annotate(
            sales=Sum('grand_total')
        ).order_by('date_of_sale')
        
        # Format sales trend
        sales_trend = [
            {
                'month': item['month'],
                'sales': float(item['sales'] or 0)
            }
            for item in monthly_sales
        ]
        
        # =====================================================
        # RECENT TRANSACTIONS (Last 10)
        # =====================================================
        
        recent_sales = Sales.objects.filter(
            is_active=True
        ).select_related('customer').order_by('-date_of_sale')[:10]
        
        recent_transactions = [
            {
                'id': str(sale.id),
                'type': 'Sale',
                'customer': sale.customer_name or 'Walk-in Customer',
                'amount': float(sale.grand_total),
                'date': sale.date_of_sale.isoformat(),
                'status': sale.status
            }
            for sale in recent_sales
        ]
        
        # =====================================================
        # ASSEMBLE RESPONSE
        # =====================================================
        
        analytics_data = {
            # Sales metrics
            'total_sales': float(total_sales),
            'total_sales_count': total_sales_count,
            
            # Order metrics ⭐ NEW
            'total_orders': total_orders,
            'pending_orders': pending_orders,
            
            # Customer metrics ⭐ NEW
            'total_customers': total_customers,
            'active_customers': active_customers,
            
            # Vendor metrics ⭐ NEW
            'total_vendors': total_vendors,
            'active_vendors': active_vendors,
            
            # Product metrics ⭐ NEW
            'total_products': total_products,
            'low_stock_products': low_stock_products,
            
            # Financial metrics
            'total_revenue': float(total_revenue),
            'total_expenses': float(total_expenses),
            'net_profit': float(net_profit),
            'profit_margin': float(profit_margin),
            
            # This month metrics
            'this_month_sales': float(this_month_sales),
            'this_month_sales_count': this_month_sales_count,
            
            # Recent activity
            'recent_sales_count': recent_sales_count,
            'recent_orders_count': recent_orders_count,
            
            # Collections
            'top_selling_products': top_selling_products,
            'sales_trend': sales_trend,
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
        today_sales = Sales.objects.filter(
            is_active=True,
            date_of_sale=today
        ).aggregate(
            total=Sum('grand_total'),
            count=Count('id')
        )
        
        # Today's orders
        today_orders = Order.objects.filter(
            is_active=True,
            order_date=today
        ).count()
        
        # Active sessions (customers who made purchases in last hour)
        one_hour_ago = now - timedelta(hours=1)
        active_sessions = Sales.objects.filter(
            is_active=True,
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
                is_active=True,
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