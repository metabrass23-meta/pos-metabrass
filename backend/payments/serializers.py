from rest_framework import serializers
from .models import Payment
from labors.models import Labor
from vendors.models import Vendor
from orders.models import Order
from sales.models import Sales


class PaymentSerializer(serializers.ModelSerializer):
    """Serializer for Payment model"""
    
    created_by = serializers.StringRelatedField(read_only=True)
    created_by_id = serializers.IntegerField(read_only=True, source='created_by.id')
    labor_name = serializers.CharField(read_only=True)
    labor_phone = serializers.CharField(read_only=True)
    labor_role = serializers.CharField(read_only=True)
    formatted_amount = serializers.CharField(read_only=True)
    net_amount = serializers.DecimalField(read_only=True, max_digits=12, decimal_places=2)
    payment_period_display = serializers.CharField(read_only=True)
    has_receipt = serializers.BooleanField(read_only=True)
    
    class Meta:
        model = Payment
        fields = (
            'id', 
            'labor', 
            'vendor', 
            'order', 
            'sale',
            'payer_type', 
            'payer_id',
            'labor_name', 
            'labor_phone', 
            'labor_role',
            'amount_paid', 
            'bonus', 
            'deduction',
            'payment_month', 
            'is_final_payment',
            'payment_method', 
            'description',
            'date', 
            'time',
            'receipt_image_path',
            'is_active',
            'created_at', 
            'updated_at',
            'created_by',
            'created_by_id',
            'formatted_amount',
            'net_amount',
            'payment_period_display',
            'has_receipt'
        )
        read_only_fields = (
            'id', 'created_at', 'updated_at', 'created_by', 'created_by_id',
            'labor_name', 'labor_phone', 'labor_role', 'payer_id',
            'formatted_amount', 'net_amount', 'payment_period_display', 'has_receipt'
        )
    
    def validate(self, data):
        """Validate payment data"""
        # Check that at least one entity is specified
        if not any([data.get('labor'), data.get('vendor'), data.get('order'), data.get('sale')]):
            raise serializers.ValidationError(
                "At least one entity (labor, vendor, order, or sale) must be specified."
            )
        
        # Validate amount
        if data.get('amount_paid', 0) <= 0:
            raise serializers.ValidationError(
                {'amount_paid': 'Amount paid must be greater than zero.'}
            )
        
        # Validate bonus and deduction
        if data.get('bonus', 0) < 0:
            raise serializers.ValidationError(
                {'bonus': 'Bonus cannot be negative.'}
            )
        
        if data.get('deduction', 0) < 0:
            raise serializers.ValidationError(
                {'deduction': 'Deduction cannot be negative.'}
            )
        
        return data
    
    def validate_labor(self, value):
        """Validate labor if specified"""
        if value and not value.is_active:
            raise serializers.ValidationError(
                "Cannot make payment to inactive labor."
            )
        return value
    
    def validate_vendor(self, value):
        """Validate vendor if specified"""
        if value and not value.is_active:
            raise serializers.ValidationError(
                "Cannot make payment to inactive vendor."
            )
        return value
    
    def validate_order(self, value):
        """Validate order if specified"""
        if value and not value.is_active:
            raise serializers.ValidationError(
                "Cannot make payment for inactive order."
            )
        return value
    
    def validate_sale(self, value):
        """Validate sale if specified"""
        if value and not value.is_active:
            raise serializers.ValidationError(
                "Cannot make payment for inactive sale."
            )
        return value


class PaymentCreateSerializer(PaymentSerializer):
    """Serializer for creating payments with additional validation"""
    
    class Meta(PaymentSerializer.Meta):
        fields = (
            'labor', 'vendor', 'order', 'sale',
            'amount_paid', 'bonus', 'deduction',
            'payment_month', 'is_final_payment',
            'payment_method', 'description',
            'date', 'time', 'receipt_image_path'
        )
    
    def create(self, validated_data):
        """Create payment with the requesting user as creator"""
        user = self.context['request'].user
        validated_data['created_by'] = user
        return super().create(validated_data)


class PaymentListSerializer(serializers.ModelSerializer):
    """Minimal serializer for listing payments"""
    
    created_by_email = serializers.CharField(source='created_by.email', read_only=True)
    formatted_amount = serializers.CharField(read_only=True)
    net_amount = serializers.DecimalField(read_only=True, max_digits=12, decimal_places=2)
    payment_period_display = serializers.CharField(read_only=True)
    
    class Meta:
        model = Payment
        fields = (
            'id',
            'labor_name',
            'vendor',
            'payer_type',
            'amount_paid',
            'bonus',
            'deduction',
            'net_amount',
            'payment_month',
            'payment_period_display',
            'is_final_payment',
            'payment_method',
            'date',
            'time',
            'has_receipt',
            'is_active',
            'created_at',
            'created_by_email'
        )


class PaymentUpdateSerializer(serializers.ModelSerializer):
    """Serializer for updating payments"""
    
    class Meta:
        model = Payment
        fields = (
            'amount_paid', 'bonus', 'deduction',
            'payment_month', 'is_final_payment',
            'payment_method', 'description',
            'date', 'time', 'receipt_image_path'
        )
    
    def validate_amount_paid(self, value):
        """Validate amount paid"""
        if value <= 0:
            raise serializers.ValidationError(
                "Amount paid must be greater than zero."
            )
        return value


class PaymentDetailSerializer(PaymentSerializer):
    """Detailed serializer for payment information"""
    
    labor_details = serializers.SerializerMethodField()
    vendor_details = serializers.SerializerMethodField()
    order_details = serializers.SerializerMethodField()
    sale_details = serializers.SerializerMethodField()
    
    class Meta(PaymentSerializer.Meta):
        fields = PaymentSerializer.Meta.fields + (
            'labor_details', 'vendor_details', 'order_details', 'sale_details'
        )
    
    def get_labor_details(self, obj):
        """Get labor details if available"""
        if obj.labor:
            return {
                'id': obj.labor.id,
                'name': obj.labor.name,
                'phone': obj.labor.phone_number,
                'designation': obj.labor.designation,
                'city': obj.labor.city,
                'area': obj.labor.area
            }
        return None
    
    def get_vendor_details(self, obj):
        """Get vendor details if available"""
        if obj.vendor:
            return {
                'id': obj.vendor.id,
                'name': obj.vendor.name,
                'business_name': obj.vendor.business_name,
                'phone': obj.vendor.phone,
                'city': obj.vendor.city,
                'area': obj.vendor.area
            }
        return None
    
    def get_order_details(self, obj):
        """Get order details if available"""
        if obj.order:
            return {
                'id': obj.order.id,
                'customer_name': obj.order.customer_name,
                'total_amount': float(obj.order.total_amount),
                'status': obj.order.status,
                'date_ordered': obj.order.date_ordered
            }
        return None
    
    def get_sale_details(self, obj):
        """Get sale details if available"""
        if obj.sale:
            return {
                'id': obj.sale.id,
                'invoice_number': obj.sale.invoice_number,
                'customer_name': obj.sale.customer_name,
                'grand_total': float(obj.sale.grand_total),
                'status': obj.sale.status,
                'date_of_sale': obj.sale.date_of_sale
            }
        return None
