from django.contrib import admin
from django.utils.html import format_html
from django.db.models import Sum, Count
from django.utils import timezone
from decimal import Decimal
from .models import Sales, SaleItem


@admin.register(SaleItem)
class SaleItemAdmin(admin.ModelAdmin):
    """Admin interface for SaleItem model"""
    
    list_display = [
        'id', 'product_name', 'sale_invoice', 'quantity', 'unit_price', 
        'item_discount', 'line_total', 'is_active'
    ]
    
    list_filter = [
        'is_active', 'created_at', 'product'
    ]
    
    search_fields = [
        'product_name', 'customization_notes', 'sale__invoice_number'
    ]
    
    readonly_fields = [
        'id', 'created_at', 'updated_at', 'line_total'
    ]
    
    fieldsets = (
        ('Sale Item Information', {
            'fields': ('id', 'sale', 'order_item', 'product')
        }),
        ('Product Details', {
            'fields': ('product_name', 'unit_price', 'quantity', 'item_discount')
        }),
        ('Financial', {
            'fields': ('line_total',)
        }),
        ('Customization', {
            'fields': ('customization_notes',)
        }),
        ('Status', {
            'fields': ('is_active',)
        }),
        ('Metadata', {
            'fields': ('created_at', 'updated_at'),
            'classes': ('collapse',)
        }),
    )
    
    list_per_page = 25
    ordering = ('-created_at',)
    
    def sale_invoice(self, obj):
        """Display sale invoice number"""
        if obj.sale:
            return format_html(
                '<strong>{}</strong>',
                obj.sale.invoice_number
            )
        return '-'
    sale_invoice.short_description = 'Sale Invoice'
    
    def get_queryset(self, request):
        """Optimize queryset with select_related"""
        return super().get_queryset(request).select_related(
            'sale', 'product', 'order_item'
        )


@admin.register(Sales)
class SalesAdmin(admin.ModelAdmin):
    """Admin interface for Sales model"""
    
    list_display = [
        'invoice_number', 'customer_name', 'status', 'grand_total', 
        'amount_paid', 'payment_status', 'payment_method', 'date_of_sale', 
        'total_items', 'is_active'
    ]
    
    list_filter = [
        'status', 'payment_method', 'is_fully_paid', 'is_active', 
        'date_of_sale', 'created_at'
    ]
    
    search_fields = [
        'invoice_number', 'customer_name', 'customer_phone', 
        'customer_email', 'notes'
    ]
    
    readonly_fields = [
        'id', 'invoice_number', 'created_at', 'updated_at', 
        'subtotal', 'tax_amount', 'grand_total', 'remaining_amount',
        'is_fully_paid', 'total_items', 'sales_age_days',
        'payment_percentage', 'sales_summary', 'authorized_initials',
        'invoice_display', 'payment_status_display', 'tax_breakdown'
    ]
    
    fieldsets = (
        ('Sale Information', {
            'fields': ('id', 'invoice_number', 'order_id', 'status', 'date_of_sale')
        }),
        ('Customer Information', {
            'fields': ('customer', 'customer_name', 'customer_phone', 'customer_email')
        }),
        ('Financial Details', {
            'fields': ('subtotal', 'overall_discount', 'gst_percentage', 'tax_amount', 'grand_total')
        }),
        ('Payment Information', {
            'fields': ('amount_paid', 'remaining_amount', 'is_fully_paid', 'payment_method', 'split_payment_details')
        }),
        ('Sale Analytics', {
            'fields': ('total_items', 'sales_age_days', 'payment_percentage', 'sales_summary'),
            'classes': ('collapse',)
        }),
        ('Additional Information', {
            'fields': ('notes',)
        }),
        ('Status', {
            'fields': ('is_active',)
        }),
        ('Metadata', {
            'fields': ('created_at', 'updated_at', 'created_by'),
            'classes': ('collapse',)
        }),
    )
    
    list_per_page = 25
    date_hierarchy = 'date_of_sale'
    ordering = ('-date_of_sale', '-created_at')
    
    actions = [
        'mark_as_active', 'mark_as_inactive', 'confirm_sales', 'mark_as_invoiced',
        'mark_as_paid', 'mark_as_delivered', 'cancel_sales', 'return_sales',
        'recalculate_totals', 'generate_monthly_report'
    ]
    
    def get_queryset(self, request):
        """Optimize queryset with select_related"""
        return super().get_queryset(request).select_related(
            'customer', 'order_id', 'created_by'
        ).prefetch_related('sale_items')
    
    def payment_status(self, obj):
        """Display payment status with color coding"""
        if obj.is_fully_paid:
            return format_html(
                '<span style="color: green; font-weight: bold;">✓ Fully Paid</span>'
            )
        elif obj.amount_paid > 0:
            return format_html(
                '<span style="color: orange; font-weight: bold;">⚠ Partial ({:.1f}%)</span>',
                obj.payment_percentage
            )
        else:
            return format_html(
                '<span style="color: red; font-weight: bold;">✗ Unpaid</span>'
            )
    payment_status.short_description = 'Payment Status'
    
    def total_items(self, obj):
        """Display total items count"""
        return obj.total_items
    total_items.short_description = 'Items'
    
    def sales_age_days(self, obj):
        """Display sales age in days"""
        return obj.sales_age_days
    sales_age_days.short_description = 'Age (Days)'
    
    def payment_percentage(self, obj):
        """Display payment percentage"""
        return f"{obj.payment_percentage:.1f}%"
    payment_percentage.short_description = 'Payment %'
    
    def sales_summary(self, obj):
        """Display sales summary"""
        return obj.sales_summary
    sales_summary.short_description = 'Summary'
    
    def authorized_initials(self, obj):
        """Display authorized initials"""
        return obj.authorized_initials
    authorized_initials.short_description = 'Authorized By'
    
    def invoice_display(self, obj):
        """Display formatted invoice number"""
        return obj.invoice_display
    invoice_display.short_description = 'Invoice #'
    
    def payment_status_display(self, obj):
        """Display payment status"""
        return obj.payment_status_display
    payment_status_display.short_description = 'Payment Status'
    
    def tax_breakdown(self, obj):
        """Display tax breakdown"""
        breakdown = obj.tax_breakdown
        return f"Taxable: PKR {breakdown['taxable_amount']:,.2f}, GST: {breakdown['tax_rate_display']} = PKR {breakdown['gst_amount']:,.2f}"
    tax_breakdown.short_description = 'Tax Breakdown'
    
    # Admin Actions
    def mark_as_active(self, request, queryset):
        """Mark selected sales as active"""
        updated = queryset.update(is_active=True)
        self.message_user(request, f'{updated} sales marked as active.')
    mark_as_active.short_description = "Mark selected sales as active"
    
    def mark_as_inactive(self, request, queryset):
        """Mark selected sales as inactive"""
        updated = queryset.update(is_active=False)
        self.message_user(request, f'{updated} sales marked as inactive.')
    mark_as_inactive.short_description = "Mark selected sales as inactive"
    
    def confirm_sales(self, request, queryset):
        """Mark selected sales as confirmed"""
        updated = queryset.filter(status='DRAFT').update(status='CONFIRMED')
        self.message_user(request, f'{updated} sales confirmed.')
    confirm_sales.short_description = "Confirm selected draft sales"
    
    def mark_as_invoiced(self, request, queryset):
        """Mark selected sales as invoiced"""
        updated = queryset.filter(status='CONFIRMED').update(status='INVOICED')
        self.message_user(request, f'{updated} sales marked as invoiced.')
    mark_as_invoiced.short_description = "Mark selected sales as invoiced"
    
    def mark_as_paid(self, request, queryset):
        """Mark selected sales as paid"""
        updated = queryset.filter(status='INVOICED').update(status='PAID')
        self.message_user(request, f'{updated} sales marked as paid.')
    mark_as_paid.short_description = "Mark selected sales as paid"
    
    def mark_as_delivered(self, request, queryset):
        """Mark selected sales as delivered"""
        updated = queryset.filter(status='PAID').update(status='DELIVERED')
        self.message_user(request, f'{updated} sales marked as delivered.')
    mark_as_delivered.short_description = "Mark selected sales as delivered"
    
    def cancel_sales(self, request, queryset):
        """Cancel selected sales"""
        updated = queryset.filter(status__in=['DRAFT', 'CONFIRMED', 'INVOICED']).update(status='CANCELLED')
        self.message_user(request, f'{updated} sales cancelled.')
    cancel_sales.short_description = "Cancel selected sales"
    
    def return_sales(self, request, queryset):
        """Mark selected sales as returned"""
        updated = queryset.filter(status='DELIVERED').update(status='RETURNED')
        self.message_user(request, f'{updated} sales marked as returned.')
    return_sales.short_description = "Mark selected sales as returned"
    
    def recalculate_totals(self, request, queryset):
        """Recalculate totals for selected sales"""
        updated = 0
        for sale in queryset:
            sale.recalculate_totals()
            updated += 1
        self.message_user(request, f'Totals recalculated for {updated} sales.')
    recalculate_totals.short_description = "Recalculate totals for selected sales"
    
    def generate_monthly_report(self, request, queryset):
        """Generate monthly sales report"""
        today = timezone.now().date()
        month_start = today.replace(day=1)
        
        monthly_sales = queryset.filter(
            date_of_sale__date__gte=month_start,
            date_of_sale__date__lte=today
        )
        
        total_sales = monthly_sales.count()
        total_revenue = monthly_sales.aggregate(total=Sum('grand_total'))['total'] or Decimal('0.00')
        total_items = monthly_sales.aggregate(total=Sum('total_items'))['total'] or 0
        
        self.message_user(
            request, 
            f'Monthly Report ({month_start.strftime("%B %Y")}): '
            f'{total_sales} sales, {total_items} items, '
            f'Revenue: PKR {total_revenue:,.2f}'
        )
    generate_monthly_report.short_description = "Generate monthly sales report"
