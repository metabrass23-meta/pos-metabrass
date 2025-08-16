from django.contrib.auth import get_user_model
from rest_framework import serializers
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from django.db import transaction
from decimal import Decimal
from .models import Sales, SaleItem
from customers.models import Customer
from products.models import Product
from orders.models import Order
from order_items.models import OrderItem


class SaleItemSerializer(serializers.ModelSerializer):
    """Complete serializer for SaleItem model"""
    
    # Product details
    product_id = serializers.UUIDField(source='product.id', read_only=True)
    product_name = serializers.CharField(read_only=True)
    
    # Computed fields
    discounted_unit_price = serializers.DecimalField(max_digits=12, decimal_places=2, read_only=True)
    total_before_discount = serializers.DecimalField(max_digits=15, decimal_places=2, read_only=True)
    discount_percentage = serializers.DecimalField(max_digits=5, decimal_places=2, read_only=True)
    formatted_line_total = serializers.CharField(read_only=True)
    product_info_at_sale = serializers.JSONField(read_only=True)
    
    class Meta:
        model = SaleItem
        fields = (
            'id', 'sale', 'order_item', 'product', 'product_id', 'product_name',
            'unit_price', 'quantity', 'item_discount', 'line_total',
            'customization_notes', 'discounted_unit_price', 'total_before_discount',
            'discount_percentage', 'formatted_line_total', 'product_info_at_sale',
            'is_active', 'created_at', 'updated_at'
        )
        read_only_fields = (
            'id', 'product_id', 'product_name', 'line_total', 'discounted_unit_price',
            'total_before_discount', 'discount_percentage', 'formatted_line_total',
            'product_info_at_sale', 'created_at', 'updated_at'
        )
    
    def validate_quantity(self, value):
        """Validate quantity against available stock"""
        if value <= 0:
            raise serializers.ValidationError("Quantity must be greater than zero.")
        
        # Check if we have a product to validate against
        if self.instance and self.instance.product:
            if value > self.instance.product.quantity:
                raise serializers.ValidationError(
                    f"Insufficient stock. Only {self.instance.product.quantity} available."
                )
        
        return value
    
    def validate_unit_price(self, value):
        """Validate unit price"""
        if value < 0:
            raise serializers.ValidationError("Unit price cannot be negative.")
        return value
    
    def validate_item_discount(self, value):
        """Validate item discount"""
        if value < 0:
            raise serializers.ValidationError("Item discount cannot be negative.")
        
        # Get the unit price for validation
        unit_price = self.initial_data.get('unit_price', 0)
        quantity = self.initial_data.get('quantity', 1)
        max_discount = unit_price * quantity
        
        if value > max_discount:
            raise serializers.ValidationError(
                f"Item discount cannot exceed line total (PKR {max_discount:,.2f})."
            )
        
        return value


class SaleItemCreateSerializer(serializers.ModelSerializer):
    """Serializer for creating sale items"""
    
    class Meta:
        model = SaleItem
        fields = (
            'sale', 'order_item', 'product', 'unit_price', 'quantity',
            'item_discount', 'customization_notes'
        )
    
    def validate(self, attrs):
        """Validate sale item data"""
        product = attrs.get('product')
        quantity = attrs.get('quantity', 0)
        unit_price = attrs.get('unit_price', 0)
        
        if product and quantity > product.quantity:
            raise serializers.ValidationError(
                f"Insufficient stock. Only {product.quantity} available for {product.name}."
            )
        
        if unit_price < 0:
            raise serializers.ValidationError("Unit price cannot be negative.")
        
        return attrs


class SaleItemUpdateSerializer(serializers.ModelSerializer):
    """Serializer for updating sale items"""
    
    class Meta:
        model = SaleItem
        fields = (
            'unit_price', 'quantity', 'item_discount', 'customization_notes'
        )
    
    def validate(self, attrs):
        """Validate update data"""
        instance = self.instance
        if instance:
            new_quantity = attrs.get('quantity', instance.quantity)
            product = instance.product
            
            if new_quantity > product.quantity:
                raise serializers.ValidationError(
                    f"Insufficient stock. Only {product.quantity} available for {product.name}."
                )
        
        return attrs


class SaleItemListSerializer(serializers.ModelSerializer):
    """Minimal serializer for listing sale items"""
    
    product_name = serializers.CharField(read_only=True)
    sale_invoice = serializers.CharField(source='sale.invoice_number', read_only=True)
    
    class Meta:
        model = SaleItem
        fields = (
            'id', 'product_name', 'sale_invoice', 'quantity', 'unit_price',
            'item_discount', 'line_total', 'is_active', 'created_at'
        )


class SalesSerializer(serializers.ModelSerializer):
    """Complete serializer for Sales model"""
    
    # Customer details
    customer_id = serializers.UUIDField(source='customer.id', read_only=True)
    customer_name = serializers.CharField(read_only=True)
    customer_phone = serializers.CharField(read_only=True)
    customer_email = serializers.EmailField(read_only=True)
    
    # Order details
    order_id = serializers.UUIDField(source='order_id.id', read_only=True)
    
    # Sale items
    sale_items = SaleItemSerializer(many=True, read_only=True)
    
    # Computed fields
    sales_age_days = serializers.IntegerField(read_only=True)
    formatted_grand_total = serializers.CharField(read_only=True)
    formatted_remaining_amount = serializers.CharField(read_only=True)
    payment_percentage = serializers.DecimalField(max_digits=5, decimal_places=2, read_only=True)
    sales_summary = serializers.CharField(read_only=True)
    authorized_initials = serializers.CharField(read_only=True)
    invoice_display = serializers.CharField(read_only=True)
    payment_status_display = serializers.CharField(read_only=True)
    total_items = serializers.IntegerField(read_only=True)
    tax_breakdown = serializers.JSONField(read_only=True)
    
    # Status display
    status_display = serializers.CharField(source='get_status_display', read_only=True)
    payment_method_display = serializers.CharField(source='get_payment_method_display', read_only=True)
    
    class Meta:
        model = Sales
        fields = (
            'id', 'invoice_number', 'order_id', 'customer_id', 'customer_name',
            'customer_phone', 'customer_email', 'subtotal', 'overall_discount',
            'gst_percentage', 'tax_amount', 'grand_total', 'amount_paid',
            'remaining_amount', 'is_fully_paid', 'payment_method',
            'split_payment_details', 'date_of_sale', 'status', 'status_display',
            'notes', 'sale_items', 'sales_age_days', 'formatted_grand_total',
            'formatted_remaining_amount', 'payment_percentage', 'sales_summary',
            'authorized_initials', 'invoice_display', 'payment_status_display',
            'total_items', 'tax_breakdown', 'payment_method_display',
            'is_active', 'created_at', 'updated_at'
        )
        read_only_fields = (
            'id', 'invoice_number', 'customer_id', 'customer_name', 'customer_phone',
            'customer_email', 'subtotal', 'tax_amount', 'grand_total', 'remaining_amount',
            'is_fully_paid', 'sales_age_days', 'formatted_grand_total',
            'formatted_remaining_amount', 'payment_percentage', 'sales_summary',
            'authorized_initials', 'invoice_display', 'payment_status_display',
            'total_items', 'tax_breakdown', 'status_display', 'payment_method_display',
            'created_at', 'updated_at'
        )
    
    def validate_overall_discount(self, value):
        """Validate overall discount"""
        if value < 0:
            raise serializers.ValidationError("Overall discount cannot be negative.")
        return value
    
    def validate_gst_percentage(self, value):
        """Validate GST percentage"""
        if value < 0 or value > 100:
            raise serializers.ValidationError("GST percentage must be between 0 and 100.")
        return value
    
    def validate_amount_paid(self, value):
        """Validate amount paid"""
        if value < 0:
            raise serializers.ValidationError("Amount paid cannot be negative.")
        return value
    
    def validate_split_payment_details(self, value):
        """Validate split payment details"""
        if self.initial_data.get('payment_method') == 'SPLIT' and not value:
            raise serializers.ValidationError("Split payment details are required when payment method is Split.")
        return value


class SalesCreateSerializer(serializers.ModelSerializer):
    """Serializer for creating sales"""
    
    sale_items = SaleItemCreateSerializer(many=True, required=False)
    
    class Meta:
        model = Sales
        fields = (
            'order_id', 'customer', 'overall_discount', 'gst_percentage',
            'amount_paid', 'payment_method', 'split_payment_details',
            'date_of_sale', 'status', 'notes', 'sale_items'
        )
    
    def validate(self, attrs):
        """Validate sale data"""
        customer = attrs.get('customer')
        payment_method = attrs.get('payment_method', 'CASH')
        split_payment_details = attrs.get('split_payment_details', {})
        
        # Validate split payment details
        if payment_method == 'SPLIT' and not split_payment_details:
            raise serializers.ValidationError(
                "Split payment details are required when payment method is Split."
            )
        
        # Validate customer exists
        if customer and not Customer.objects.filter(id=customer.id, is_active=True).exists():
            raise serializers.ValidationError("Invalid or inactive customer.")
        
        return attrs
    
    @transaction.atomic
    def create(self, validated_data):
        """Create sale with items"""
        sale_items_data = validated_data.pop('sale_items', [])
        
        # Create the sale
        sale = Sales.objects.create(**validated_data)
        
        # Create sale items
        for item_data in sale_items_data:
            SaleItem.objects.create(sale=sale, **item_data)
        
        # Recalculate totals
        sale.recalculate_totals()
        
        return sale


class SalesUpdateSerializer(serializers.ModelSerializer):
    """Serializer for updating sales"""
    
    class Meta:
        model = Sales
        fields = (
            'overall_discount', 'gst_percentage', 'amount_paid', 'payment_method',
            'split_payment_details', 'status', 'notes'
        )
    
    def validate_status(self, value):
        """Validate status transitions"""
        if self.instance:
            current_status = self.instance.status
            
            # Prevent changing status of delivered, cancelled, or returned sales
            if current_status in ['DELIVERED', 'CANCELLED', 'RETURNED'] and value != current_status:
                raise serializers.ValidationError(
                    f"Cannot change status of {current_status.lower()} sales."
                )
            
            # Validate logical status progression
            valid_transitions = {
                'DRAFT': ['CONFIRMED', 'CANCELLED'],
                'CONFIRMED': ['INVOICED', 'CANCELLED'],
                'INVOICED': ['PAID', 'CANCELLED'],
                'PAID': ['DELIVERED', 'CANCELLED'],
                'DELIVERED': ['RETURNED'],  # Can only be returned
                'CANCELLED': [],  # Terminal state
                'RETURNED': []    # Terminal state
            }
            
            if value != current_status and value not in valid_transitions.get(current_status, []):
                raise serializers.ValidationError(
                    f"Invalid status transition from {current_status} to {value}."
                )
        
        return value


class SalesListSerializer(serializers.ModelSerializer):
    """Minimal serializer for listing sales"""
    
    customer_name = serializers.CharField(read_only=True)
    status_display = serializers.CharField(source='get_status_display', read_only=True)
    payment_method_display = serializers.CharField(source='get_payment_method_display', read_only=True)
    payment_status = serializers.CharField(source='payment_status_display', read_only=True)
    
    class Meta:
        model = Sales
        fields = (
            'id', 'invoice_number', 'customer_name', 'status', 'status_display',
            'grand_total', 'amount_paid', 'payment_status', 'payment_method',
            'payment_method_display', 'date_of_sale', 'total_items', 'is_active',
            'created_at'
        )


class SalesPaymentSerializer(serializers.Serializer):
    """Serializer for recording payments"""
    
    amount = serializers.DecimalField(
        max_digits=15,
        decimal_places=2,
        help_text="Payment amount"
    )
    payment_method = serializers.ChoiceField(
        choices=Sales.PAYMENT_METHOD_CHOICES,
        help_text="Method of payment"
    )
    split_payment_details = serializers.JSONField(
        required=False,
        help_text="Details for split payments"
    )
    notes = serializers.CharField(
        max_length=1000,
        required=False,
        help_text="Payment notes"
    )
    
    def validate_amount(self, value):
        """Validate payment amount"""
        if value <= 0:
            raise serializers.ValidationError("Payment amount must be positive.")
        return value
    
    def validate(self, attrs):
        """Validate payment data"""
        payment_method = attrs.get('payment_method')
        split_payment_details = attrs.get('split_payment_details', {})
        
        if payment_method == 'SPLIT' and not split_payment_details:
            raise serializers.ValidationError(
                "Split payment details are required when payment method is Split."
            )
        
        return attrs


class SalesStatusUpdateSerializer(serializers.Serializer):
    """Serializer for updating sale status"""
    
    status = serializers.ChoiceField(
        choices=Sales.STATUS_CHOICES,
        help_text="New sale status"
    )
    notes = serializers.CharField(
        max_length=1000,
        required=False,
        help_text="Optional status update notes"
    )


class SalesBulkActionSerializer(serializers.Serializer):
    """Serializer for bulk sale actions"""
    
    action = serializers.ChoiceField(
        choices=[
            ('activate', 'Activate'),
            ('deactivate', 'Deactivate'),
            ('confirm', 'Confirm'),
            ('invoice', 'Mark as Invoiced'),
            ('mark_paid', 'Mark as Paid'),
            ('deliver', 'Mark as Delivered'),
            ('cancel', 'Cancel'),
            ('return', 'Mark as Returned'),
            ('recalculate', 'Recalculate Totals'),
        ],
        help_text="Action to perform on selected sales"
    )
    sale_ids = serializers.ListField(
        child=serializers.UUIDField(),
        help_text="List of sale IDs to perform action on"
    )


class SalesStatisticsSerializer(serializers.Serializer):
    """Serializer for sales statistics"""
    
    total_sales = serializers.IntegerField()
    total_revenue = serializers.DecimalField(max_digits=15, decimal_places=2)
    total_items_sold = serializers.IntegerField()
    average_sale_value = serializers.DecimalField(max_digits=15, decimal_places=2)
    payment_completion_rate = serializers.DecimalField(max_digits=5, decimal_places=2)
    top_products = serializers.ListField()
    top_customers = serializers.ListField()
    monthly_trends = serializers.ListField()


class OrderToSaleConversionSerializer(serializers.Serializer):
    """Serializer for converting orders to sales"""
    
    order_id = serializers.UUIDField(
        help_text="ID of the order to convert"
    )
    payment_method = serializers.ChoiceField(
        choices=Sales.PAYMENT_METHOD_CHOICES,
        help_text="Method of payment for the sale"
    )
    amount_paid = serializers.DecimalField(
        max_digits=15,
        decimal_places=2,
        default=Decimal('0.00'),
        help_text="Amount paid immediately"
    )
    overall_discount = serializers.DecimalField(
        max_digits=12,
        decimal_places=2,
        default=Decimal('0.00'),
        help_text="Overall discount to apply"
    )
    gst_percentage = serializers.DecimalField(
        max_digits=5,
        decimal_places=2,
        default=Decimal('17.00'),
        help_text="GST percentage to apply"
    )
    notes = serializers.CharField(
        max_length=1000,
        required=False,
        help_text="Additional sale notes"
    )
    partial_items = serializers.ListField(
        child=serializers.DictField(),
        required=False,
        help_text="List of order items to convert with quantities"
    )
    
    def validate_order_id(self, value):
        """Validate order exists and can be converted"""
        try:
            order = Order.objects.get(id=value, is_active=True)
            
            if order.status not in ['READY', 'DELIVERED']:
                raise serializers.ValidationError(
                    f"Order must be in READY or DELIVERED status to convert to sale. Current status: {order.status}"
                )
            
            if order.has_been_converted_to_sale():
                raise serializers.ValidationError(
                    "This order has already been converted to a sale."
                )
            
        except Order.DoesNotExist:
            raise serializers.ValidationError("Order not found or inactive.")
        
        return value
    
    def validate_amount_paid(self, value):
        """Validate amount paid"""
        if value < 0:
            raise serializers.ValidationError("Amount paid cannot be negative.")
        return value
    
    def validate_overall_discount(self, value):
        """Validate overall discount"""
        if value < 0:
            raise serializers.ValidationError("Overall discount cannot be negative.")
        return value
    
    def validate_gst_percentage(self, value):
        """Validate GST percentage"""
        if value < 0 or value > 100:
            raise serializers.ValidationError("GST percentage must be between 0 and 100.")
        return value
