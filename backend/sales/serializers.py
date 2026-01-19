from django.contrib.auth import get_user_model
from rest_framework import serializers
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from django.db import transaction
from decimal import Decimal
from .models import Sales, SaleItem, TaxRate, Invoice, Receipt, Return, ReturnItem, Refund
from customers.models import Customer
from products.models import Product
from orders.models import Order
from order_items.models import OrderItem


class TaxRateSerializer(serializers.ModelSerializer):
    """Serializer for TaxRate model"""
    
    is_currently_effective = serializers.BooleanField(read_only=True)
    display_name = serializers.CharField(read_only=True)
    
    class Meta:
        model = TaxRate
        fields = (
            'id', 'name', 'tax_type', 'percentage', 'is_active', 'description',
            'effective_from', 'effective_to', 'is_currently_effective', 'display_name',
            'created_at', 'updated_at'
        )
        read_only_fields = ('id', 'created_at', 'updated_at')


class SaleItemCreateSerializer(serializers.Serializer):
    """Nested serializer for creating sale items within a sale"""
    
    product = serializers.UUIDField(help_text="Product UUID")
    unit_price = serializers.DecimalField(max_digits=12, decimal_places=2)
    quantity = serializers.IntegerField()
    item_discount = serializers.DecimalField(max_digits=12, decimal_places=2, default=Decimal('0.00'))
    customization_notes = serializers.CharField(max_length=500, required=False, allow_blank=True)
    
    def validate_product(self, value):
        """Validate product exists and is active"""
        try:
            product = Product.objects.get(id=value, is_active=True)
            return product
        except Product.DoesNotExist:
            raise serializers.ValidationError("Invalid product or product is not active.")
    
    def validate_quantity(self, value):
        """Validate quantity"""
        if value <= 0:
            raise serializers.ValidationError("Quantity must be greater than zero.")
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
        return value


class SalesCreateSerializer(serializers.ModelSerializer):
    """Serializer for creating sales WITH sale_items support"""
    
    # Add sale_items as write-only field
    sale_items = SaleItemCreateSerializer(many=True, write_only=True)
    
    # Add amount_paid as optional field
    amount_paid = serializers.DecimalField(
        max_digits=15,
        decimal_places=2,
        default=Decimal('0.00'),
        help_text="Amount paid immediately"
    )
    
    class Meta:
        model = Sales
        fields = (
            'order_id', 
            'customer', 
            'overall_discount', 
            'tax_configuration',
            'payment_method', 
            'amount_paid',
            'split_payment_details', 
            'notes',
            'sale_items'
        )
    
    def validate_customer(self, value):
        """Validate customer exists and is active"""
        if not value.is_active:
            raise serializers.ValidationError("Customer must be active.")
        return value
    
    def validate_tax_configuration(self, value):
        """Validate tax configuration for new sales"""
        if not value:
            # Use default tax configuration if none provided
            return {}
        
        if not isinstance(value, dict):
            raise serializers.ValidationError("Tax configuration must be a valid JSON object.")
        
        # Validate each tax entry
        for tax_type, tax_data in value.items():
            if not isinstance(tax_data, dict):
                raise serializers.ValidationError(f"Tax data for {tax_type} must be a valid object.")
            
            if 'percentage' not in tax_data:
                raise serializers.ValidationError(f"Tax data for {tax_type} must include percentage.")
            
            percentage = tax_data['percentage']
            if not isinstance(percentage, (int, float, Decimal)) or percentage < 0 or percentage > 100:
                raise serializers.ValidationError(f"Tax percentage for {tax_type} must be between 0 and 100.")
        
        return value
    
    def validate_amount_paid(self, value):
        """Validate amount paid"""
        if value < 0:
            raise serializers.ValidationError("Amount paid cannot be negative.")
        return value
    
    def validate_sale_items(self, value):
        """Validate sale items list is not empty"""
        if not value:
            raise serializers.ValidationError("At least one sale item is required.")
        return value
    
    def create(self, validated_data):
        """Create sale with items in a transaction"""
        from django.db import transaction
        
        # Extract sale_items from validated_data
        sale_items_data = validated_data.pop('sale_items')
        
        # Extract amount_paid if present
        amount_paid = validated_data.pop('amount_paid', Decimal('0.00'))
        
        with transaction.atomic():
            # Create the sale
            validated_data['amount_paid'] = amount_paid
            sale = Sales.objects.create(**validated_data)
            
            # Create sale items
            for item_data in sale_items_data:
                product = item_data['product']
                
                SaleItem.objects.create(
                    sale=sale,
                    product=product,
                    unit_price=item_data['unit_price'],
                    quantity=item_data['quantity'],
                    item_discount=item_data.get('item_discount', Decimal('0.00')),
                    customization_notes=item_data.get('customization_notes', '')
                )
            
            # Recalculate sale totals
            sale.recalculate_totals()
            
        return sale


class SaleItemSerializer(serializers.ModelSerializer):
    """Complete serializer for SaleItem model"""
    
    product_id = serializers.UUIDField(source='product.id', read_only=True)
    product_name = serializers.CharField(read_only=True)
    discounted_unit_price = serializers.DecimalField(max_digits=12, decimal_places=2, read_only=True)
    total_before_discount = serializers.DecimalField(max_digits=15, decimal_places=2, read_only=True)
    discount_percentage = serializers.DecimalField(max_digits=5, decimal_places=2, read_only=True)
    formatted_line_total = serializers.CharField(read_only=True)
    
    class Meta:
        model = SaleItem
        fields = (
            'id', 'sale', 'order_item', 'product', 'product_id', 'product_name',
            'unit_price', 'quantity', 'item_discount', 'line_total',
            'customization_notes', 'discounted_unit_price', 'total_before_discount',
            'discount_percentage', 'formatted_line_total',
            'is_active', 'created_at', 'updated_at'
        )
        read_only_fields = (
            'id', 'product_id', 'product_name', 'line_total', 'discounted_unit_price',
            'total_before_discount', 'discount_percentage', 'formatted_line_total',
            'created_at', 'updated_at'
        )


class SaleItemUpdateSerializer(serializers.ModelSerializer):
    """Serializer for updating sale items"""
    
    class Meta:
        model = SaleItem
        fields = (
            'unit_price', 'quantity', 'item_discount', 'customization_notes'
        )
    
    def validate(self, data):
        """Validate updated sale item data"""
        quantity = data.get('quantity', self.instance.quantity)
        unit_price = data.get('unit_price', self.instance.unit_price)
        
        if self.instance.product and quantity > self.instance.product.quantity:
            raise serializers.ValidationError(
                f"Insufficient stock. Only {self.instance.product.quantity} available for {self.instance.product.name}."
            )
        
        if unit_price < 0:
            raise serializers.ValidationError("Unit price cannot be negative.")
        
        if quantity <= 0:
            raise serializers.ValidationError("Quantity must be greater than zero.")
        
        return data


class SaleItemListSerializer(serializers.ModelSerializer):
    """Simplified serializer for listing sale items"""
    
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
    
    sale_items = SaleItemSerializer(many=True, read_only=True)
    payment_method_display = serializers.CharField(source='get_payment_method_display', read_only=True)
    status_display = serializers.CharField(source='get_status_display', read_only=True)
    tax_breakdown = serializers.JSONField(read_only=True)
    tax_summary_display = serializers.CharField(read_only=True)
    
    class Meta:
        model = Sales
        fields = (
            'id', 'invoice_number', 'order_id', 'customer_id', 'customer_name',
            'customer_phone', 'customer_email', 'subtotal', 'overall_discount',
            'tax_configuration', 'gst_percentage', 'tax_amount', 'grand_total', 'amount_paid',
            'remaining_amount', 'is_fully_paid', 'payment_method', 'payment_method_display',
            'split_payment_details', 'date_of_sale', 'status', 'status_display',
            'notes', 'sale_items', 'sales_age_days', 'formatted_grand_total',
            'formatted_remaining_amount', 'payment_percentage', 'sales_summary',
            'authorized_initials', 'invoice_display', 'payment_status_display',
            'total_items', 'tax_breakdown', 'tax_summary_display',
            'is_active', 'created_at', 'updated_at'
        )
        read_only_fields = (
            'id', 'invoice_number', 'customer_id', 'customer_name', 'customer_phone',
            'customer_email', 'subtotal', 'tax_amount', 'grand_total', 'remaining_amount',
            'sales_age_days', 'formatted_grand_total', 'formatted_remaining_amount',
            'payment_percentage', 'sales_summary', 'authorized_initials',
            'invoice_display', 'payment_status_display', 'total_items', 'tax_breakdown',
            'status_display', 'payment_method_display', 'tax_summary_display',
            'created_at', 'updated_at'
        )
    
    def validate_overall_discount(self, value):
        """Validate overall discount"""
        if value < 0:
            raise serializers.ValidationError("Overall discount cannot be negative.")
        return value
    
    def validate_tax_configuration(self, value):
        """Validate tax configuration"""
        if not isinstance(value, dict):
            raise serializers.ValidationError("Tax configuration must be a valid JSON object.")
        
        # Validate each tax entry
        for tax_type, tax_data in value.items():
            if not isinstance(tax_data, dict):
                raise serializers.ValidationError(f"Tax data for {tax_type} must be a valid object.")
            
            if 'percentage' not in tax_data:
                raise serializers.ValidationError(f"Tax data for {tax_type} must include percentage.")
            
            percentage = tax_data['percentage']
            if not isinstance(percentage, (int, float, Decimal)) or percentage < 0 or percentage > 100:
                raise serializers.ValidationError(f"Tax percentage for {tax_type} must be between 0 and 100.")
        
        return value
    
    def validate_amount_paid(self, value):
        """Validate amount paid"""
        if value < 0:
            raise serializers.ValidationError("Amount paid cannot be negative.")
        return value


class SalesUpdateSerializer(serializers.ModelSerializer):
    """Serializer for updating sales"""
    
    class Meta:
        model = Sales
        fields = (
            'overall_discount', 'tax_configuration', 'payment_method',
            'split_payment_details', 'notes', 'status'
        )
    
    def validate_tax_configuration(self, value):
        """Validate tax configuration updates"""
        if not value:
            return value
        
        if not isinstance(value, dict):
            raise serializers.ValidationError("Tax configuration must be a valid JSON object.")
        
        # Validate each tax entry
        for tax_type, tax_data in value.items():
            if not isinstance(tax_data, dict):
                raise serializers.ValidationError(f"Tax data for {tax_type} must be a valid object.")
            
            if 'percentage' not in tax_data:
                raise serializers.ValidationError(f"Tax data for {tax_type} must include percentage.")
            
            percentage = tax_data['percentage']
            if not isinstance(percentage, (int, float, Decimal)) or percentage < 0 or percentage > 100:
                raise serializers.ValidationError(f"Tax percentage for {tax_type} must be between 0 and 100.")
        
        return value
    
    def validate_status(self, value):
        """Validate status transitions"""
        instance = self.instance
        if instance and instance.status in ['PAID', 'DELIVERED']:
            raise serializers.ValidationError("Cannot change status of completed sales.")
        return value


class SalesListSerializer(serializers.ModelSerializer):
    """Simplified serializer for listing sales"""
    
    payment_method_display = serializers.CharField(source='get_payment_method_display', read_only=True)
    status_display = serializers.CharField(source='get_status_display', read_only=True)
    tax_summary_display = serializers.CharField(read_only=True)
    
    class Meta:
        model = Sales
        fields = (
            'id', 'invoice_number', 'customer_name', 'status', 'status_display',
            'grand_total', 'amount_paid', 'payment_method', 'payment_method_display',
            'date_of_sale', 'total_items', 'tax_summary_display', 'is_active'
        )


class SalesPaymentSerializer(serializers.ModelSerializer):
    """Serializer for updating payment information"""
    
    class Meta:
        model = Sales
        fields = ('amount_paid', 'payment_method', 'split_payment_details')
    
    def validate_amount_paid(self, value):
        """Validate amount paid"""
        if value < 0:
            raise serializers.ValidationError("Amount paid cannot be negative.")
        
        if value > self.instance.grand_total:
            raise serializers.ValidationError("Amount paid cannot exceed grand total.")
        
        return value


class SalesStatusUpdateSerializer(serializers.ModelSerializer):
    """Serializer for updating sale status"""
    
    class Meta:
        model = Sales
        fields = ('status',)
    
    def validate_status(self, value):
        """Validate status transitions"""
        instance = self.instance
        if instance.status in ['PAID', 'DELIVERED']:
            raise serializers.ValidationError("Cannot change status of completed sales.")
        return value


class SalesBulkActionSerializer(serializers.Serializer):
    """Serializer for bulk sales actions"""
    
    action = serializers.ChoiceField(choices=[
        ('activate', 'Activate'),
        ('deactivate', 'Deactivate'),
        ('confirm', 'Confirm'),
        ('invoice', 'Mark as Invoiced'),
        ('cancel', 'Cancel'),
        ('delete', 'Delete')
    ])
    
    sale_ids = serializers.ListField(
        child=serializers.UUIDField(),
        help_text="List of sale IDs to perform action on"
    )


class SalesStatisticsSerializer(serializers.Serializer):
    """Serializer for sales statistics"""
    
    total_sales = serializers.IntegerField()
    total_revenue = serializers.DecimalField(max_digits=15, decimal_places=2)
    total_items_sold = serializers.IntegerField()
    average_order_value = serializers.DecimalField(max_digits=15, decimal_places=2)
    total_tax_collected = serializers.DecimalField(max_digits=15, decimal_places=2)
    tax_breakdown = serializers.JSONField()
    payment_method_distribution = serializers.JSONField()
    status_distribution = serializers.JSONField()
    daily_trends = serializers.ListField()
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
    tax_configuration = serializers.JSONField(
        required=False,
        help_text="Tax configuration for the sale"
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
            if order.status not in ['CONFIRMED', 'IN_PROGRESS']:
                raise serializers.ValidationError("Order must be confirmed or in progress to convert to sale.")
        except Order.DoesNotExist:
            raise serializers.ValidationError("Order not found or inactive.")
        
        return value
    
    def validate_tax_configuration(self, value):
        """Validate tax configuration"""
        if not value:
            return value
        
        if not isinstance(value, dict):
            raise serializers.ValidationError("Tax configuration must be a valid JSON object.")
        
        # Validate each tax entry
        for tax_type, tax_data in value.items():
            if not isinstance(tax_data, dict):
                raise serializers.ValidationError(f"Tax data for {tax_type} must be a valid object.")
            
            if 'percentage' not in tax_data:
                raise serializers.ValidationError(f"Tax data for {tax_type} must include percentage.")
            
            percentage = tax_data['percentage']
            if not isinstance(percentage, (int, float, Decimal)) or percentage < 0 or percentage > 100:
                raise serializers.ValidationError(f"Tax percentage for {tax_type} must be between 0 and 100.")
        
        return value


# Invoice Serializers
class InvoiceSerializer(serializers.ModelSerializer):
    """Serializer for Invoice model"""
    
    sale_invoice_number = serializers.CharField(source='sale.invoice_number', read_only=True)
    customer_name = serializers.CharField(source='sale.customer_name', read_only=True)
    customer_phone = serializers.CharField(source='sale.customer_phone', read_only=True)
    created_by_name = serializers.CharField(source='created_by.username', read_only=True)
    is_overdue = serializers.BooleanField(read_only=True)
    days_until_due = serializers.IntegerField(read_only=True)
    
    class Meta:
        model = Invoice
        fields = (
            'id', 'sale', 'sale_invoice_number', 'invoice_number', 'issue_date', 'due_date',
            'status', 'notes', 'terms_conditions', 'pdf_file', 'email_sent', 'email_sent_at',
            'viewed_at', 'is_active', 'created_at', 'updated_at', 'created_by', 'created_by_name',
            'customer_name', 'customer_phone', 'is_overdue', 'days_until_due'
        )
        read_only_fields = (
            'id', 'invoice_number', 'email_sent', 'email_sent_at', 'viewed_at', 'is_active',
            'created_at', 'updated_at', 'sale_invoice_number', 'customer_name', 'customer_phone',
            'created_by_name', 'is_overdue', 'days_until_due'
        )


class InvoiceCreateSerializer(serializers.ModelSerializer):
    """Serializer for creating invoices"""
    
    class Meta:
        model = Invoice
        fields = ('sale', 'due_date', 'notes', 'terms_conditions')
    
    def validate(self, data):
        """Validate invoice data"""
        sale = data.get('sale')
        
        # Validate sale exists and is active
        if not sale or not sale.is_active:
            raise serializers.ValidationError("Invalid or inactive sale.")
        
        # Check if invoice already exists for this sale
        if hasattr(sale, 'invoice'):
            raise serializers.ValidationError("Invoice already exists for this sale.")
        
        return data
    
    def create(self, validated_data):
        """Create invoice"""
        validated_data['created_by'] = self.context['request'].user
        return super().create(validated_data)


class InvoiceUpdateSerializer(serializers.ModelSerializer):
    """Serializer for updating invoices"""
    
    class Meta:
        model = Invoice
        fields = ('due_date', 'status', 'notes', 'terms_conditions')


class InvoiceListSerializer(serializers.ModelSerializer):
    """Serializer for listing invoices"""
    
    sale_invoice_number = serializers.CharField(source='sale.invoice_number', read_only=True)
    customer_name = serializers.CharField(source='sale.customer_name', read_only=True)
    customer_phone = serializers.CharField(source='sale.customer_phone', read_only=True)
    grand_total = serializers.DecimalField(source='sale.grand_total', max_digits=15, decimal_places=2, read_only=True)
    
    class Meta:
        model = Invoice
        fields = (
            'id', 'sale', 'sale_invoice_number', 'invoice_number', 'issue_date', 'due_date',
            'status', 'customer_name', 'customer_phone', 'grand_total', 'created_at'
        )


# Receipt Serializers
class ReceiptSerializer(serializers.ModelSerializer):
    """Serializer for Receipt model"""
    
    sale_invoice_number = serializers.CharField(source='sale.invoice_number', read_only=True)
    payment_amount = serializers.DecimalField(source='payment.amount', max_digits=15, decimal_places=2, read_only=True)
    payment_method = serializers.CharField(source='payment.payment_method', read_only=True)
    customer_name = serializers.CharField(source='sale.customer_name', read_only=True)
    customer_phone = serializers.CharField(source='sale.customer_phone', read_only=True)
    created_by_name = serializers.CharField(source='created_by.username', read_only=True)
    
    class Meta:
        model = Receipt
        fields = (
            'id', 'sale', 'payment', 'receipt_number', 'generated_at', 'status',
            'pdf_file', 'email_sent', 'email_sent_at', 'viewed_at', 'notes',
            'is_active', 'created_at', 'updated_at', 'created_by', 'created_by_name',
            'sale_invoice_number', 'payment_amount', 'payment_method', 'customer_name', 'customer_phone'
        )
        read_only_fields = (
            'id', 'receipt_number', 'generated_at', 'email_sent', 'email_sent_at', 'viewed_at',
            'is_active', 'created_at', 'updated_at', 'sale_invoice_number', 'payment_amount',
            'payment_method', 'customer_name', 'customer_phone', 'created_by_name'
        )


class ReceiptCreateSerializer(serializers.ModelSerializer):
    """Serializer for creating receipts"""
    
    class Meta:
        model = Receipt
        fields = ('sale', 'payment', 'notes')
    
    def validate(self, data):
        """Validate receipt data"""
        sale = data.get('sale')
        payment = data.get('payment')
        
        # Validate sale exists and is active
        if not sale or not sale.is_active:
            raise serializers.ValidationError("Invalid or inactive sale.")
        
        # Validate payment exists and belongs to the sale
        if not payment or payment.entity_id != str(sale.id) or payment.entity_type != 'sale':
            raise serializers.ValidationError("Invalid payment or payment doesn't belong to this sale.")
        
        return data
    
    def create(self, validated_data):
        """Create receipt"""
        validated_data['created_by'] = self.context['request'].user
        return super().create(validated_data)


class ReceiptUpdateSerializer(serializers.ModelSerializer):
    """Serializer for updating receipts"""
    
    class Meta:
        model = Receipt
        fields = ('status', 'notes')


class ReceiptListSerializer(serializers.ModelSerializer):
    """Serializer for listing receipts"""
    
    sale_invoice_number = serializers.CharField(source='sale.invoice_number', read_only=True)
    payment_amount = serializers.DecimalField(source='payment.amount', max_digits=15, decimal_places=2, read_only=True)
    payment_method = serializers.CharField(source='payment.payment_method', read_only=True)
    customer_name = serializers.CharField(source='sale.customer_name', read_only=True)
    
    class Meta:
        model = Receipt
        fields = (
            'id', 'sale', 'payment', 'receipt_number', 'generated_at', 'status',
            'customer_name', 'sale_invoice_number', 'payment_amount', 'payment_method', 'created_at'
        )