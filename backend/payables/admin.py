from django.contrib import admin
from django.utils.html import format_html
from django.urls import reverse
from django.utils.safestring import mark_safe
from django.db.models import Count, Sum
from django.utils import timezone
from decimal import Decimal
from .models import Payable, PayablePayment


class PayablePaymentInline(admin.TabularInline):
    """Inline for payable payments"""
    model = PayablePayment
    extra = 0
    readonly_fields = ('id', 'created_at', 'created_by')
    fields = ('amount', 'payment_date', 'notes', 'created_at', 'created_by')
    
    def has_delete_permission(self, request, obj=None):
        return False  # Prevent deletion of payments from inline


@admin.register(Payable)
class PayableAdmin(admin.ModelAdmin):
    list_display = (
        'creditor_name_formatted',
        'amount_display',
        'balance_display',
        'payment_progress',
        'expected_repayment_date_formatted',
        'status_badge',
        'priority_badge',
        'overdue_indicator',
        'created_at'
    )
    
    list_filter = (
        'status',
        'priority',
        'is_fully_paid',
        'is_active',
        'expected_repayment_date',
        'date_borrowed',
        'created_at',
    )
    
    search_fields = (
        'creditor_name',
        'creditor_phone',
        'creditor_email',
        'reason_or_item',
        'notes',
        'vendor__name',
        'vendor__business_name',
    )
    
    readonly_fields = (
        'id',
        'balance_remaining',
        'is_fully_paid',
        'payment_percentage',
        'days_since_borrowed',
        'days_until_due',
        'is_overdue',
        'repayment_status',
        'priority_color',
        'status_color',
        'created_at',
        'updated_at',
        'created_by',
    )
    
    fieldsets = (
        ('Creditor Information', {
            'fields': ('id', 'creditor_name', 'creditor_phone', 'creditor_email', 'vendor')
        }),
        ('Amount Details', {
            'fields': (
                'amount_borrowed', 'amount_paid', 'balance_remaining',
                'payment_percentage', 'is_fully_paid'
            )
        }),
        ('Description & Dates', {
            'fields': (
                'reason_or_item', 'date_borrowed', 'expected_repayment_date',
                'days_since_borrowed', 'days_until_due', 'is_overdue'
            )
        }),
        ('Status & Priority', {
            'fields': (
                'status', 'priority', 'repayment_status',
                'priority_color', 'status_color'
            )
        }),
        ('Additional Information', {
            'fields': ('notes', 'is_active'),
            'classes': ('collapse',)
        }),
        ('Metadata', {
            'fields': ('created_at', 'updated_at', 'created_by'),
            'classes': ('collapse',)
        }),
    )
    
    inlines = [PayablePaymentInline]
    
    list_per_page = 25
    date_hierarchy = 'expected_repayment_date'
    ordering = ('-expected_repayment_date', '-created_at')
    
    actions = [
        'mark_as_urgent',
        'mark_as_high_priority',
        'mark_as_medium_priority',
        'mark_as_low_priority',
        'mark_as_active',
        'mark_as_inactive',
        'cancel_payables',
        'export_payable_summary',
    ]

    def get_queryset(self, request):
        """Optimize queryset with select_related"""
        return super().get_queryset(request).select_related('created_by', 'vendor')

    def creditor_name_formatted(self, obj):
        """Display formatted creditor name with vendor info"""
        if obj.vendor:
            return format_html(
                '<strong>{}</strong><br>'
                '<small style="color: #666;">🏢 {}</small>',
                obj.creditor_name,
                obj.vendor.business_name
            )
        return format_html('<strong>{}</strong>', obj.creditor_name)
    creditor_name_formatted.short_description = 'Creditor'
    creditor_name_formatted.admin_order_field = 'creditor_name'

    def amount_display(self, obj):
        """Display amount borrowed with formatting"""
        return format_html(
            '<strong>₹{:,.2f}</strong><br>'
            '<small style="color: #666;">Borrowed</small>',
            obj.amount_borrowed
        )
    amount_display.short_description = 'Amount Borrowed'
    amount_display.admin_order_field = 'amount_borrowed'

    def balance_display(self, obj):
        """Display remaining balance with color coding"""
        if obj.is_fully_paid:
            color = '#28a745'  # Green
            text = '✅ Paid'
        elif obj.balance_remaining > obj.amount_borrowed * Decimal('0.8'):
            color = '#dc3545'  # Red - most amount remaining
            text = f'₹{obj.balance_remaining:,.2f}'
        elif obj.balance_remaining > obj.amount_borrowed * Decimal('0.5'):
            color = '#fd7e14'  # Orange - moderate amount remaining
            text = f'₹{obj.balance_remaining:,.2f}'
        else:
            color = '#ffc107'  # Yellow - small amount remaining
            text = f'₹{obj.balance_remaining:,.2f}'
        
        return format_html(
            '<span style="color: {}; font-weight: bold;">{}</span><br>'
            '<small style="color: #666;">Remaining</small>',
            color, text
        )
    balance_display.short_description = 'Balance'
    balance_display.admin_order_field = 'balance_remaining'

    def payment_progress(self, obj):
        """Display payment progress bar"""
        percentage = float(obj.payment_percentage)
        
        if percentage >= 100:
            color = '#28a745'  # Green
        elif percentage >= 75:
            color = '#ffc107'  # Yellow
        elif percentage >= 50:
            color = '#fd7e14'  # Orange
        else:
            color = '#dc3545'  # Red
        
        return format_html(
            '<div style="width: 100px; background-color: #e9ecef; border-radius: 3px; overflow: hidden;">'
            '<div style="width: {}%; height: 15px; background-color: {}; '
            'transition: width 0.3s ease;"></div>'
            '</div>'
            '<small>{:.1f}%</small>',
            min(percentage, 100), color, percentage
        )
    payment_progress.short_description = 'Progress'

    def expected_repayment_date_formatted(self, obj):
        """Display due date with urgency indicators"""
        if not obj.expected_repayment_date:
            return '—'
        
        days_until_due = obj.days_until_due
        
        if obj.is_overdue:
            color = '#dc3545'  # Red
            icon = '🚨'
            text = f'{abs(days_until_due)} days overdue'
        elif days_until_due <= 3:
            color = '#fd7e14'  # Orange
            icon = '⚠️'
            text = f'{days_until_due} days left'
        elif days_until_due <= 7:
            color = '#ffc107'  # Yellow
            icon = '📅'
            text = f'{days_until_due} days left'
        else:
            color = '#28a745'  # Green
            icon = '📅'
            text = f'{days_until_due} days left'
        
        return format_html(
            '{} <span style="color: {};">{}</span><br>'
            '<small>{}</small>',
            icon, color, obj.expected_repayment_date.strftime('%Y-%m-%d'), text
        )
    expected_repayment_date_formatted.short_description = 'Due Date'
    expected_repayment_date_formatted.admin_order_field = 'expected_repayment_date'

    def status_badge(self, obj):
        """Display status badge with color"""
        return format_html(
            '<span style="background-color: {}; color: white; padding: 3px 8px; '
            'border-radius: 3px; font-size: 11px; font-weight: bold;">{}</span>',
            obj.status_color, obj.get_status_display()
        )
    status_badge.short_description = 'Status'
    status_badge.admin_order_field = 'status'

    def priority_badge(self, obj):
        """Display priority badge with color"""
        return format_html(
            '<span style="background-color: {}; color: white; padding: 3px 8px; '
            'border-radius: 3px; font-size: 11px; font-weight: bold;">{}</span>',
            obj.priority_color, obj.get_priority_display()
        )
    priority_badge.short_description = 'Priority'
    priority_badge.admin_order_field = 'priority'

    def overdue_indicator(self, obj):
        """Display overdue indicator"""
        if obj.is_fully_paid:
            return format_html(
                '<span style="color: #28a745; font-size: 16px;">✅</span>'
            )
        elif obj.is_overdue:
            return format_html(
                '<span style="color: #dc3545; font-size: 16px;" title="Overdue">🚨</span>'
            )
        elif obj.days_until_due <= 3:
            return format_html(
                '<span style="color: #fd7e14; font-size: 16px;" title="Due soon">⚠️</span>'
            )
        else:
            return format_html(
                '<span style="color: #28a745; font-size: 16px;" title="On track">📅</span>'
            )
    overdue_indicator.short_description = 'Status'

    def save_model(self, request, obj, form, change):
        """Set created_by when creating new payable"""
        if not change:  # Creating new payable
            obj.created_by = request.user
        super().save_model(request, obj, form, change)

    # Custom admin actions
    def mark_as_urgent(self, request, queryset):
        """Mark selected payables as urgent priority"""
        updated = queryset.update(priority='URGENT')
        self.message_user(
            request,
            f'{updated} payables were successfully marked as urgent priority.'
        )
    mark_as_urgent.short_description = 'Mark as URGENT priority'

    def mark_as_high_priority(self, request, queryset):
        """Mark selected payables as high priority"""
        updated = queryset.update(priority='HIGH')
        self.message_user(
            request,
            f'{updated} payables were successfully marked as high priority.'
        )
    mark_as_high_priority.short_description = 'Mark as HIGH priority'

    def mark_as_medium_priority(self, request, queryset):
        """Mark selected payables as medium priority"""
        updated = queryset.update(priority='MEDIUM')
        self.message_user(
            request,
            f'{updated} payables were successfully marked as medium priority.'
        )
    mark_as_medium_priority.short_description = 'Mark as MEDIUM priority'

    def mark_as_low_priority(self, request, queryset):
        """Mark selected payables as low priority"""
        updated = queryset.update(priority='LOW')
        self.message_user(
            request,
            f'{updated} payables were successfully marked as low priority.'
        )
    mark_as_low_priority.short_description = 'Mark as LOW priority'

    def mark_as_active(self, request, queryset):
        """Mark selected payables as active"""
        updated = queryset.update(is_active=True)
        self.message_user(
            request,
            f'{updated} payables were successfully marked as active.'
        )
    mark_as_active.short_description = 'Mark selected payables as active'

    def mark_as_inactive(self, request, queryset):
        """Mark selected payables as inactive"""
        updated = queryset.update(is_active=False)
        self.message_user(
            request,
            f'{updated} payables were successfully marked as inactive.'
        )
    mark_as_inactive.short_description = 'Mark selected payables as inactive'

    def cancel_payables(self, request, queryset):
        """Cancel selected payables"""
        count = 0
        for payable in queryset:
            if payable.status != 'CANCELLED':
                payable.cancel("Cancelled via admin action")
                count += 1
        
        self.message_user(
            request,
            f'{count} payables were successfully cancelled.'
        )
    cancel_payables.short_description = 'Cancel selected payables'

    def export_payable_summary(self, request, queryset):
        """Show payable summary for export"""
        count = queryset.count()
        total_borrowed = queryset.aggregate(total=Sum('amount_borrowed'))['total'] or Decimal('0.00')
        total_outstanding = queryset.aggregate(total=Sum('balance_remaining'))['total'] or Decimal('0.00')
        
        overdue_count = queryset.filter(
            expected_repayment_date__lt=timezone.now().date(),
            is_fully_paid=False
        ).count()
        
        urgent_count = queryset.filter(priority='URGENT').count()
        
        self.message_user(
            request,
            f'Selected {count} payables for export. '
            f'Total borrowed: ₹{total_borrowed:,.2f}, '
            f'Total outstanding: ₹{total_outstanding:,.2f}, '
            f'Overdue: {overdue_count}, '
            f'Urgent: {urgent_count}'
        )
    export_payable_summary.short_description = 'Show export summary'

    def changelist_view(self, request, extra_context=None):
        """Add extra context to changelist view"""
        extra_context = extra_context or {}
        
        # Get payable statistics
        stats = Payable.get_statistics()
        
        extra_context.update({
            'total_payables': stats['total_payables'],
            'overdue_payables': stats['overdue_payables'],
            'urgent_payables': stats['urgent_payables'],
            'total_outstanding': stats['total_outstanding_amount'],
            'overdue_amount': stats['overdue_amount'],
            'top_creditors': stats['top_creditors'][:3],  # Show top 3 creditors
        })
        
        return super().changelist_view(request, extra_context)


@admin.register(PayablePayment)
class PayablePaymentAdmin(admin.ModelAdmin):
    list_display = (
        'payable_creditor_formatted',
        'amount_formatted',
        'payment_date',
        'notes_preview',
        'created_at',
        'created_by'
    )
    
    list_filter = (
        'payment_date',
        'created_at',
        'payable__status',
        'payable__priority',
    )
    
    search_fields = (
        'payable__creditor_name',
        'notes',
        'payable__reason_or_item',
    )
    
    readonly_fields = (
        'id',
        'created_at',
        'created_by',
        'payable_info',
    )
    
    fieldsets = (
        ('Payment Information', {
            'fields': ('id', 'payable', 'payable_info', 'amount', 'payment_date')
        }),
        ('Additional Details', {
            'fields': ('notes',)
        }),
        ('Metadata', {
            'fields': ('created_at', 'created_by'),
            'classes': ('collapse',)
        }),
    )
    
    list_per_page = 30
    date_hierarchy = 'payment_date'
    ordering = ('-payment_date', '-created_at')

    def get_queryset(self, request):
        """Optimize queryset with select_related"""
        return super().get_queryset(request).select_related('payable', 'created_by')

    def payable_creditor_formatted(self, obj):
        """Display creditor name with payable link"""
        payable_url = reverse('admin:payables_payable_change', args=[obj.payable.pk])
        return format_html(
            '<a href="{}" style="text-decoration: none;">'
            '<strong>{}</strong></a><br>'
            '<small style="color: #666;">Balance: ₹{:,.2f}</small>',
            payable_url, obj.payable.creditor_name, obj.payable.balance_remaining
        )
    payable_creditor_formatted.short_description = 'Payable'
    payable_creditor_formatted.admin_order_field = 'payable__creditor_name'

    def amount_formatted(self, obj):
        """Display formatted payment amount"""
        return format_html(
            '<strong style="color: #28a745;">₹{:,.2f}</strong>',
            obj.amount
        )
    amount_formatted.short_description = 'Amount'
    amount_formatted.admin_order_field = 'amount'

    def notes_preview(self, obj):
        """Display notes preview"""
        if obj.notes:
            preview = obj.notes[:50] + ('...' if len(obj.notes) > 50 else '')
            return format_html(
                '<span title="{}">{}</span>',
                obj.notes, preview
            )
        return '—'
    notes_preview.short_description = 'Notes'

    def payable_info(self, obj):
        """Display payable information"""
        if obj.payable:
            return format_html(
                'Creditor: <strong>{}</strong><br>'
                'Total Borrowed: ₹{:,.2f}<br>'
                'Remaining Balance: ₹{:,.2f}<br>'
                'Status: <span style="color: {};">{}</span>',
                obj.payable.creditor_name,
                obj.payable.amount_borrowed,
                obj.payable.balance_remaining,
                obj.payable.status_color,
                obj.payable.get_status_display()
            )
        return '—'
    payable_info.short_description = 'Payable Details'

    def save_model(self, request, obj, form, change):
        """Set created_by when creating new payment"""
        if not change:  # Creating new payment
            obj.created_by = request.user
        super().save_model(request, obj, form, change)

    def has_delete_permission(self, request, obj=None):
        """Restrict payment deletion"""
        # Only allow superusers to delete payments
        return request.user.is_superuser


# Custom admin site configuration
admin.site.site_header = "Payables Management System"
admin.site.site_title = "Payables Admin"
admin.site.index_title = "Welcome to Payables Management System"
