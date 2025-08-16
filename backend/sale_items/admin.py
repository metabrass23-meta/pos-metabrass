from django.contrib import admin
from sales.models import SaleItem


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
            return obj.sale.invoice_number
        return '-'
    sale_invoice.short_description = 'Sale Invoice'
    
    def get_queryset(self, request):
        """Optimize queryset with select_related"""
        return super().get_queryset(request).select_related(
            'sale', 'product', 'order_item'
        )
