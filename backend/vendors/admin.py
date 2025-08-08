from datetime import timedelta, timezone
from django.contrib import admin
from django.utils.html import format_html
from django.urls import reverse
from django.utils.safestring import mark_safe
from django.db.models import Count
from .models import Vendor, VendorNote


class VendorNoteInline(admin.TabularInline):
    """Inline admin for vendor notes"""
    model = VendorNote
    extra = 0
    fields = ('note', 'created_by', 'created_at')
    readonly_fields = ('created_by', 'created_at')
    can_delete = True
    
    def has_add_permission(self, request, obj=None):
        return True


@admin.register(Vendor)
class VendorAdmin(admin.ModelAdmin):
    """Django admin configuration for Vendor model"""
    
    # Display settings
    list_display = [
        'name', 'business_name', 'display_phone', 'city_area',
        'status_badge', 'payments_info', 'created_at'
    ]
    list_filter = [
        'is_active', 'city', 'area', 'created_at', 'updated_at'
    ]
    search_fields = [
        'name', 'business_name', 'cnic', 'phone', 'city', 'area'
    ]
    ordering = ['-created_at']
    list_per_page = 25
    
    # Form settings
    fieldsets = (
        ('Basic Information', {
            'fields': ('name', 'business_name')
        }),
        ('Contact Details', {
            'fields': ('cnic', 'phone')
        }),
        ('Location', {
            'fields': ('city', 'area')
        }),
        ('Status & Metadata', {
            'fields': ('is_active', 'created_by'),
            'classes': ('collapse',)
        }),
        ('Timestamps', {
            'fields': ('created_at', 'updated_at'),
            'classes': ('collapse',),
        }),
    )
    
    readonly_fields = ['id', 'created_at', 'updated_at', 'display_phone', 'full_address']
    
    # Inline models
    inlines = [VendorNoteInline]
    
    # Actions
    actions = ['make_active', 'make_inactive', 'export_selected_vendors']
    
    def get_queryset(self, request):
        """Optimize queryset with select_related"""
        queryset = super().get_queryset(request)
        return queryset.select_related('created_by')
    
    def get_readonly_fields(self, request, obj=None):
        """Make certain fields readonly when editing"""
        readonly = list(self.readonly_fields)
        if obj:  # Editing existing vendor
            readonly.extend(['id'])
        return readonly
    
    # Custom display methods
    def status_badge(self, obj):
        """Display status as colored badge"""
        if obj.is_active:
            return format_html(
                '<span style="color: green; font-weight: bold;">● Active</span>'
            )
        else:
            return format_html(
                '<span style="color: red; font-weight: bold;">● Inactive</span>'
            )
    status_badge.short_description = 'Status'
    status_badge.admin_order_field = 'is_active'
    
    def city_area(self, obj):
        """Display city and area together"""
        return f"{obj.city}, {obj.area}"
    city_area.short_description = 'Location'
    city_area.admin_order_field = 'city'
    
    def display_phone(self, obj):
        """Display formatted phone number"""
        return obj.display_phone
    display_phone.short_description = 'Phone'
    display_phone.admin_order_field = 'phone'
    
    def payments_info(self, obj):
        """Display payment information"""
        count = obj.get_payments_count()
        amount = obj.get_total_payments_amount()
        
        if count > 0:
            return format_html(
                '<strong>{}</strong> payments<br/><small>₹ {:,.2f} total</small>',
                count, amount
            )
        else:
            return format_html('<em>No payments</em>')
    payments_info.short_description = 'Payments'
    
    # Custom actions
    def make_active(self, request, queryset):
        """Activate selected vendors"""
        updated = queryset.update(is_active=True)
        self.message_user(
            request,
            f'{updated} vendor(s) have been activated.'
        )
    make_active.short_description = "Mark selected vendors as active"
    
    def make_inactive(self, request, queryset):
        """Deactivate selected vendors"""
        updated = queryset.update(is_active=False)
        self.message_user(
            request,
            f'{updated} vendor(s) have been deactivated.'
        )
    make_inactive.short_description = "Mark selected vendors as inactive"
    
    def export_selected_vendors(self, request, queryset):
        """Export selected vendors to CSV"""
        import csv
        from django.http import HttpResponse
        
        response = HttpResponse(content_type='text/csv')
        response['Content-Disposition'] = 'attachment; filename="vendors.csv"'
        
        writer = csv.writer(response)
        writer.writerow([
            'Name', 'Business Name', 'CNIC', 'Phone', 
            'City', 'Area', 'Status', 'Created At'
        ])
        
        for vendor in queryset:
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
    export_selected_vendors.short_description = "Export selected vendors to CSV"
    
    # Override save_model to set created_by
    def save_model(self, request, obj, form, change):
        if not change:  # Creating new vendor
            obj.created_by = request.user
        super().save_model(request, obj, form, change)
    
    # Custom views (if needed)
    def changeform_view(self, request, object_id=None, form_url='', extra_context=None):
        """Customize the change form view"""
        extra_context = extra_context or {}
        
        if object_id:
            obj = self.get_object(request, object_id)
            if obj:
                # Add custom context for the change form
                extra_context['payments_count'] = obj.get_payments_count()
                extra_context['total_payments'] = obj.get_total_payments_amount()
                extra_context['last_payment'] = obj.get_last_payment_date()
        
        return super().changeform_view(request, object_id, form_url, extra_context)


@admin.register(VendorNote)
class VendorNoteAdmin(admin.ModelAdmin):
    """Django admin configuration for VendorNote model"""
    
    list_display = ['vendor', 'note_preview', 'created_by', 'created_at']
    list_filter = ['created_at', 'created_by']
    search_fields = ['vendor__name', 'vendor__business_name', 'note']
    ordering = ['-created_at']
    list_per_page = 50
    
    fieldsets = (
        (None, {
            'fields': ('vendor', 'note')
        }),
        ('Metadata', {
            'fields': ('created_by', 'created_at'),
            'classes': ('collapse',)
        }),
    )
    
    readonly_fields = ['created_by', 'created_at']
    
    def get_queryset(self, request):
        """Optimize queryset"""
        return super().get_queryset(request).select_related('vendor', 'created_by')
    
    def note_preview(self, obj):
        """Show preview of note content"""
        if len(obj.note) > 100:
            return f"{obj.note[:97]}..."
        return obj.note
    note_preview.short_description = 'Note Preview'
    
    def save_model(self, request, obj, form, change):
        """Set created_by when saving"""
        if not change:  # Creating new note
            obj.created_by = request.user
        super().save_model(request, obj, form, change)


# Custom admin site configuration (optional)
class VendorAdminSite(admin.AdminSite):
    """Custom admin site for vendor management"""
    site_header = 'Vendor Management System'
    site_title = 'Vendor Admin'
    index_title = 'Welcome to Vendor Management'
    
    def index(self, request, extra_context=None):
        """Custom index page with vendor statistics"""
        extra_context = extra_context or {}
        
        # Add vendor statistics to context
        total_vendors = Vendor.objects.count()
        active_vendors = Vendor.objects.filter(is_active=True).count()
        recent_vendors = Vendor.objects.filter(
            created_at__gte=timezone.now() - timedelta(days=30)
        ).count()
        
        # Top cities
        top_cities = list(
            Vendor.objects
            .values('city')
            .annotate(count=Count('id'))
            .order_by('-count')[:5]
        )
        
        extra_context.update({
            'vendor_stats': {
                'total': total_vendors,
                'active': active_vendors,
                'inactive': total_vendors - active_vendors,
                'recent': recent_vendors,
                'top_cities': top_cities
            }
        })
        
        return super().index(request, extra_context)

vendor_admin_site = VendorAdminSite(name='vendor_admin')
vendor_admin_site.register(Vendor, VendorAdmin)
vendor_admin_site.register(VendorNote, VendorNoteAdmin)
