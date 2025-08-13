from django.contrib import admin
from django.utils.html import format_html
from django.urls import reverse
from django.utils import timezone
from .models import AdvancePayment


@admin.register(AdvancePayment)
class AdvancePaymentAdmin(admin.ModelAdmin):
    """Admin interface for AdvancePayment model"""
    
    list_display = [
        'labor_name_link',
        'formatted_amount_display',
        'date',
        'time',
        'advance_percentage_display',
        'receipt_status',
        'is_active',
        'created_at'
    ]
    
    list_filter = [
        'is_active',
        'date',
        'labor_role',
        'created_at',
        ('receipt_image_path', admin.EmptyFieldListFilter),
    ]
    
    search_fields = [
        'labor_name',
        'labor_phone',
        'labor_role',
        'description',
        'amount'
    ]
    
    readonly_fields = [
        'id',
        'labor_name',
        'labor_phone',
        'labor_role',
        'total_salary',
        'remaining_salary',
        'advance_percentage_display',
        'payment_datetime',
        'created_at',
        'updated_at',
        'created_by'
    ]
    
    fieldsets = (
        ('Payment Information', {
            'fields': (
                'id',
                'labor',
                'labor_name',
                'labor_phone',
                'labor_role',
                'amount',
                'description'
            )
        }),
        ('Date & Time', {
            'fields': (
                'date',
                'time',
                'payment_datetime'
            )
        }),
        ('Salary Context', {
            'fields': (
                'total_salary',
                'remaining_salary',
                'advance_percentage_display'
            )
        }),
        ('Receipt', {
            'fields': (
                'receipt_image_path',
            )
        }),
        ('System Information', {
            'fields': (
                'is_active',
                'created_at',
                'updated_at',
                'created_by'
            ),
            'classes': ('collapse',)
        }),
    )
    
    date_hierarchy = 'date'
    ordering = ['-date', '-time', '-created_at']
    
    def get_queryset(self, request):
        """Optimize queryset with select_related"""
        return super().get_queryset(request).select_related('labor', 'created_by')
    
    def labor_name_link(self, obj):
        """Display labor name with link to labor admin"""
        if obj.labor:
            url = reverse('admin:labors_labor_change', args=[obj.labor.pk])
            return format_html('<a href="{}">{}</a>', url, obj.labor_name)
        return obj.labor_name
    labor_name_link.short_description = 'Labor'
    labor_name_link.admin_order_field = 'labor_name'
    
    def formatted_amount_display(self, obj):
        """Display formatted amount with currency"""
        return f"PKR {obj.amount:,.2f}"
    formatted_amount_display.short_description = 'Amount'
    formatted_amount_display.admin_order_field = 'amount'
    
    def advance_percentage_display(self, obj):
        """Display advance as percentage of salary"""
        percentage = obj.advance_percentage
        if percentage > 80:
            color = 'red'
        elif percentage > 50:
            color = 'orange'
        else:
            color = 'green'
        
        return format_html(
            '<span style="color: {};">{:.1f}%</span>',
            color,
            percentage
        )
    advance_percentage_display.short_description = 'Advance %'
    advance_percentage_display.admin_order_field = 'amount'
    
    def receipt_status(self, obj):
        """Display receipt status with icon"""
        if obj.receipt_image_path:
            return format_html(
                '<span style="color: green;">✓ Has Receipt</span>'
            )
        else:
            return format_html(
                '<span style="color: red;">✗ No Receipt</span>'
            )
    receipt_status.short_description = 'Receipt'
    
    def payment_datetime(self, obj):
        """Display combined date and time"""
        return obj.payment_datetime.strftime('%Y-%m-%d %H:%M:%S')
    payment_datetime.short_description = 'Payment Date/Time'
    
    actions = ['make_active', 'make_inactive', 'export_to_csv']
    
    def make_active(self, request, queryset):
        """Bulk activate advance payments"""
        updated = queryset.update(is_active=True)
        self.message_user(request, f'{updated} advance payments were activated.')
    make_active.short_description = 'Activate selected advance payments'
    
    def make_inactive(self, request, queryset):
        """Bulk deactivate advance payments"""
        updated = queryset.update(is_active=False)
        self.message_user(request, f'{updated} advance payments were deactivated.')
    make_inactive.short_description = 'Deactivate selected advance payments'
    
    def export_to_csv(self, request, queryset):
        """Export selected advance payments to CSV"""
        import csv
        from django.http import HttpResponse
        
        response = HttpResponse(content_type='text/csv')
        response['Content-Disposition'] = 'attachment; filename="advance_payments.csv"'
        
        writer = csv.writer(response)
        writer.writerow([
            'ID', 'Labor Name', 'Labor Phone', 'Labor Role', 'Amount', 
            'Date', 'Time', 'Description', 'Has Receipt', 'Total Salary',
            'Advance Percentage', 'Is Active', 'Created At'
        ])
        
        for payment in queryset:
            writer.writerow([
                str(payment.id),
                payment.labor_name,
                payment.labor_phone,
                payment.labor_role,
                float(payment.amount),
                payment.date,
                payment.time,
                payment.description,
                'Yes' if payment.receipt_image_path else 'No',
                float(payment.total_salary),
                payment.advance_percentage,
                payment.is_active,
                payment.created_at.strftime('%Y-%m-%d %H:%M:%S')
            ])
        
        return response
    export_to_csv.short_description = 'Export selected payments to CSV'
    
    def has_delete_permission(self, request, obj=None):
        """Control delete permissions"""
        # Only allow superusers to delete advance payments
        return request.user.is_superuser
    
    def get_readonly_fields(self, request, obj=None):
        """Customize readonly fields based on user permissions"""
        readonly_fields = list(self.readonly_fields)
        
        # If editing existing object and user is not superuser
        if obj and not request.user.is_superuser:
            readonly_fields.extend(['labor', 'amount', 'date'])
        
        return readonly_fields
    
    class Media:
        css = {
            'all': ('admin/css/advance_payment_admin.css',)
        }
        js = ('admin/js/advance_payment_admin.js',)
        