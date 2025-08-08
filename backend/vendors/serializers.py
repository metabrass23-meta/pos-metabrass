from rest_framework import serializers
from django.contrib.auth import get_user_model
from .models import Vendor, VendorNote

# Get the custom user model
User = get_user_model()


class UserSerializer(serializers.ModelSerializer):
    """Serializer for User model"""
    
    class Meta:
        model = User
        fields = ['id', 'username', 'first_name', 'last_name', 'email']


class VendorNoteSerializer(serializers.ModelSerializer):
    """Serializer for VendorNote model"""
    
    created_by = UserSerializer(read_only=True)
    
    class Meta:
        model = VendorNote
        fields = ['id', 'note', 'created_by', 'created_at']
        read_only_fields = ['id', 'created_at']


class VendorListSerializer(serializers.ModelSerializer):
    """Serializer for Vendor list view"""
    
    payments_count = serializers.SerializerMethodField()
    total_payments_amount = serializers.SerializerMethodField()
    last_payment_date = serializers.SerializerMethodField()
    full_address = serializers.ReadOnlyField()
    initials = serializers.ReadOnlyField()
    
    class Meta:
        model = Vendor
        fields = [
            'id', 'name', 'business_name', 'cnic', 'phone',
            'city', 'area', 'full_address', 'is_active',
            'created_at', 'updated_at', 'initials',
            'payments_count', 'total_payments_amount', 'last_payment_date'
        ]
    
    def get_payments_count(self, obj):
        """Get total payments count for vendor"""
        return obj.get_payments_count()
    
    def get_total_payments_amount(self, obj):
        """Get total payments amount for vendor"""
        return obj.get_total_payments_amount()
    
    def get_last_payment_date(self, obj):
        """Get last payment date for vendor"""
        return obj.get_last_payment_date()


class VendorDetailSerializer(serializers.ModelSerializer):
    """Serializer for Vendor detail view"""
    
    created_by = UserSerializer(read_only=True)
    notes = VendorNoteSerializer(many=True, read_only=True)
    full_address = serializers.ReadOnlyField()
    initials = serializers.ReadOnlyField()
    display_phone = serializers.ReadOnlyField()
    
    # Payment statistics
    statistics = serializers.SerializerMethodField()
    recent_payments = serializers.SerializerMethodField()
    
    class Meta:
        model = Vendor
        fields = [
            'id', 'name', 'business_name', 'cnic', 'phone', 'display_phone',
            'city', 'area', 'full_address', 'is_active',
            'created_at', 'updated_at', 'created_by', 'initials',
            'notes', 'statistics', 'recent_payments'
        ]
    
    def get_statistics(self, obj):
        """Get payment statistics for vendor"""
        return {
            'total_payments': obj.get_payments_count(),
            'total_payments_amount': obj.get_total_payments_amount(),
            'first_payment_date': None,  # To be implemented with Payment model
            'last_payment_date': obj.get_last_payment_date(),
            'average_payment_amount': obj.get_average_payment_amount()
        }
    
    def get_recent_payments(self, obj):
        """Get recent payments for vendor"""
        # This will be implemented when Payment model is available
        return []


class VendorCreateUpdateSerializer(serializers.ModelSerializer):
    """Serializer for creating and updating vendors"""
    
    class Meta:
        model = Vendor
        fields = [
            'name', 'business_name', 'cnic', 'phone',
            'city', 'area', 'is_active'
        ]
        extra_kwargs = {
            'cnic': {'required': True},
            'name': {'required': True},
            'business_name': {'required': True},
            'phone': {'required': True},
            'city': {'required': True},
            'area': {'required': True},
        }
    
    def validate_cnic(self, value):
        """Validate CNIC uniqueness among active vendors"""
        # Get the instance if we're updating
        instance = getattr(self, 'instance', None)
        
        # Check if CNIC already exists for active vendors
        queryset = Vendor.objects.filter(cnic=value, is_active=True)
        if instance:
            queryset = queryset.exclude(pk=instance.pk)
        
        if queryset.exists():
            raise serializers.ValidationError(
                "An active vendor with this CNIC already exists."
            )
        
        return value
    
    def validate_phone(self, value):
        """Additional phone validation"""
        # The model's validate_pakistani_phone will handle the format validation
        return value
    
    def create(self, validated_data):
        """Create a new vendor"""
        # Set created_by if user is provided in context
        request = self.context.get('request')
        if request and hasattr(request, 'user'):
            validated_data['created_by'] = request.user
        
        return super().create(validated_data)


class VendorSearchSerializer(serializers.Serializer):
    """Serializer for vendor search parameters"""
    
    q = serializers.CharField(
        required=False,
        help_text="Search query for name, business name, phone, or CNIC"
    )
    city = serializers.CharField(
        required=False,
        help_text="Filter by city"
    )
    area = serializers.CharField(
        required=False,
        help_text="Filter by area"
    )
    is_active = serializers.BooleanField(
        required=False,
        help_text="Filter by active status"
    )
    created_after = serializers.DateField(
        required=False,
        help_text="Filter vendors created after this date"
    )
    created_before = serializers.DateField(
        required=False,
        help_text="Filter vendors created before this date"
    )
    ordering = serializers.ChoiceField(
        choices=[
            'name', '-name',
            'business_name', '-business_name',
            'created_at', '-created_at',
            'updated_at', '-updated_at',
            'city', '-city'
        ],
        required=False,
        default='-created_at',
        help_text="Order results by field"
    )


class VendorStatisticsSerializer(serializers.Serializer):
    """Serializer for vendor statistics"""
    
    total_vendors = serializers.IntegerField()
    active_vendors = serializers.IntegerField()
    inactive_vendors = serializers.IntegerField()
    new_vendors_this_month = serializers.IntegerField()
    new_vendors_this_week = serializers.IntegerField()
    new_vendors_today = serializers.IntegerField()
    top_cities = serializers.ListField(
        child=serializers.DictField()
    )
    vendors_by_month = serializers.ListField(
        child=serializers.DictField()
    )


class VendorBulkActionSerializer(serializers.Serializer):
    """Serializer for bulk actions on vendors"""
    
    vendor_ids = serializers.ListField(
        child=serializers.UUIDField(),
        min_length=1,
        help_text="List of vendor IDs to perform action on"
    )
    action = serializers.ChoiceField(
        choices=['soft_delete', 'restore', 'export'],
        help_text="Action to perform on selected vendors"
    )
    
    def validate_vendor_ids(self, value):
        """Validate that all vendor IDs exist"""
        existing_vendors = Vendor.objects.filter(id__in=value)
        if existing_vendors.count() != len(value):
            missing_ids = set(value) - set(existing_vendors.values_list('id', flat=True))
            raise serializers.ValidationError(
                f"The following vendor IDs do not exist: {list(missing_ids)}"
            )
        return value


class VendorImportSerializer(serializers.Serializer):
    """Serializer for importing vendors from CSV/Excel"""
    
    file = serializers.FileField(
        help_text="CSV or Excel file containing vendor data"
    )
    skip_duplicates = serializers.BooleanField(
        default=True,
        help_text="Skip vendors with duplicate CNIC"
    )
    update_existing = serializers.BooleanField(
        default=False,
        help_text="Update existing vendors with same CNIC"
    )
    
    def validate_file(self, value):
        """Validate uploaded file"""
        allowed_extensions = ['.csv', '.xlsx', '.xls']
        file_extension = value.name.lower().split('.')[-1]
        
        if f'.{file_extension}' not in allowed_extensions:
            raise serializers.ValidationError(
                f"Unsupported file format. Allowed formats: {', '.join(allowed_extensions)}"
            )
        
        # Check file size (limit to 10MB)
        if value.size > 10 * 1024 * 1024:
            raise serializers.ValidationError(
                "File too large. Maximum size is 10MB."
            )
        
        return value


class VendorExportSerializer(serializers.Serializer):
    """Serializer for exporting vendor data"""
    
    format = serializers.ChoiceField(
        choices=['csv', 'excel', 'pdf'],
        default='csv',
        help_text="Export format"
    )
    include_inactive = serializers.BooleanField(
        default=False,
        help_text="Include inactive vendors in export"
    )
    fields = serializers.MultipleChoiceField(
        choices=[
            'name', 'business_name', 'cnic', 'phone',
            'city', 'area', 'created_at', 'updated_at'
        ],
        required=False,
        help_text="Fields to include in export (all fields if not specified)"
    )
    date_range = serializers.CharField(
        required=False,
        help_text="Date range filter (e.g., '2024-01-01,2024-12-31')"
    )
    