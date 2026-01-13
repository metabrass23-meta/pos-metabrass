from rest_framework import serializers
from decimal import Decimal
from .models import Return, ReturnItem, Refund, SaleItem


class ReturnSerializer(serializers.ModelSerializer):
    """Serializer for Return model"""
    
    sale_invoice_number = serializers.CharField(source='sale.invoice_number', read_only=True)
    customer_name = serializers.CharField(source='customer.name', read_only=True)
    customer_phone = serializers.CharField(source='customer.phone', read_only=True)
    approved_by_name = serializers.CharField(source='approved_by.username', read_only=True)
    processed_by_name = serializers.CharField(source='processed_by.username', read_only=True)
    created_by_name = serializers.CharField(source='created_by.username', read_only=True)
    return_items_count = serializers.SerializerMethodField()
    items_count = serializers.IntegerField(read_only=True)
    
    class Meta:
        model = Return
        fields = (
            'id', 'sale', 'sale_invoice_number', 'return_number', 'customer', 'customer_name', 
            'customer_phone', 'return_date', 'status', 'reason', 'reason_details', 
            'total_return_amount', 'notes',
            'approved_by', 'approved_by_name', 'approved_at', 'processed_by', 'processed_by_name',
            'processed_at', 'is_active', 'created_at', 'updated_at', 'created_by', 'created_by_name',
            'return_items_count', 'items_count'
        )
        read_only_fields = (
            'id', 'return_number', 'return_date', 'total_return_amount', 'approved_by', 
            'approved_at', 'processed_by', 'processed_at', 'created_at', 'updated_at',
            'sale_invoice_number', 'customer_name', 'customer_phone', 'approved_by_name',
            'processed_by_name', 'created_by_name', 'return_items_count', 'items_count'
        )
    
    def get_return_items_count(self, obj):
        """Get count of return items"""
        return obj.return_items.count()


class ReturnCreateSerializer(ReturnSerializer):
    """Serializer for creating returns"""
    
    return_items = serializers.ListField(
        child=serializers.DictField(),
        write_only=True,
        help_text="List of items to return"
    )
    
    class Meta:
        model = Return
        fields = (
            'sale', 'customer', 'reason', 'reason_details', 'notes', 'return_items'
        )
    
    def validate(self, data):
        """Validate return data"""
        sale = data.get('sale')
        customer = data.get('customer')
        return_items = data.get('return_items', [])
        
        # Validate sale exists and is active
        if not sale or not sale.is_active:
            raise serializers.ValidationError("Invalid or inactive sale.")
        
        # Validate customer matches sale customer
        if customer != sale.customer:
            raise serializers.ValidationError("Customer must match the sale customer.")
        
        # Validate return items
        if not return_items:
            raise serializers.ValidationError("At least one item must be returned.")
        
        # Validate each return item
        for item_data in return_items:
            sale_item_id = item_data.get('sale_item_id')
            quantity_returned = item_data.get('quantity_returned')
            condition = item_data.get('condition', 'GOOD')
            
            if not sale_item_id:
                raise serializers.ValidationError("Sale item ID is required for each return item.")
            
            try:
                sale_item = SaleItem.objects.get(id=sale_item_id, sale=sale, is_active=True)
            except SaleItem.DoesNotExist:
                raise serializers.ValidationError(f"Sale item {sale_item_id} not found or not associated with this sale.")
            
            if quantity_returned > sale_item.quantity:
                raise serializers.ValidationError(f"Return quantity cannot exceed sold quantity for item {sale_item.product_name}.")
            
            if quantity_returned <= 0:
                raise serializers.ValidationError(f"Return quantity must be positive for item {sale_item.product_name}.")
        
        return data
    
    def create(self, validated_data):
        """Create return with return items"""
        return_items_data = validated_data.pop('return_items')
        
        # Create return
        return_request = Return.objects.create(**validated_data)
        
        # Create return items
        total_return_amount = Decimal('0.00')
        for item_data in return_items_data:
            sale_item = SaleItem.objects.get(id=item_data['sale_item_id'])
            
            return_item = ReturnItem.objects.create(
                return_request=return_request,
                sale_item=sale_item,
                product=sale_item.product,
                quantity_returned=item_data['quantity_returned'],
                original_quantity=sale_item.quantity,
                original_price=sale_item.unit_price,
                condition=item_data.get('condition', 'GOOD'),
                condition_notes=item_data.get('condition_notes', '')
            )
            
            total_return_amount += return_item.return_amount
        
        # Update total return amount
        return_request.total_return_amount = total_return_amount
        return_request.save()
        
        return return_request


class ReturnUpdateSerializer(ReturnSerializer):
    """Serializer for updating returns"""
    
    class Meta:
        model = Return
        fields = ('reason_details', 'notes')
    
    def validate(self, data):
        """Validate update data"""
        if self.instance.status not in ['PENDING']:
            raise serializers.ValidationError("Return can only be updated when status is PENDING.")
        return data


class ReturnItemSerializer(serializers.ModelSerializer):
    """Serializer for ReturnItem model"""
    
    product_name = serializers.CharField(source='product.name', read_only=True)
    sale_item_id = serializers.UUIDField(source='sale_item.id', read_only=True)
    
    class Meta:
        model = ReturnItem
        fields = (
            'id', 'return_request', 'sale_item', 'sale_item_id', 'product', 'product_name',
            'quantity_returned', 'original_quantity', 'original_price', 'return_amount',
            'condition', 'condition_notes', 'is_active', 'created_at', 'updated_at'
        )
        read_only_fields = (
            'id', 'return_request', 'sale_item', 'sale_item_id', 'product', 'product_name',
            'original_quantity', 'original_price', 'return_amount', 'created_at', 'updated_at'
        )


class RefundSerializer(serializers.ModelSerializer):
    """Serializer for Refund model"""
    
    return_number = serializers.CharField(source='return_request.return_number', read_only=True)
    sale_invoice_number = serializers.CharField(source='return_request.sale.invoice_number', read_only=True)
    customer_name = serializers.CharField(source='return_request.customer.name', read_only=True)
    processed_by_name = serializers.CharField(source='processed_by.username', read_only=True)
    created_by_name = serializers.CharField(source='created_by.username', read_only=True)
    
    class Meta:
        model = Refund
        fields = (
            'id', 'return_request', 'return_number', 'sale_invoice_number', 'customer_name',
            'refund_number', 'refund_date', 'amount', 'method', 'status', 'reference_number',
            'notes', 'processed_by', 'processed_by_name', 'processed_at', 'is_active',
            'created_at', 'updated_at', 'created_by', 'created_by_name'
        )
        read_only_fields = (
            'id', 'refund_number', 'refund_date', 'status', 'processed_by', 'processed_at',
            'created_at', 'updated_at', 'return_number', 'sale_invoice_number', 'customer_name',
            'processed_by_name', 'created_by_name'
        )


class RefundCreateSerializer(RefundSerializer):
    """Serializer for creating refunds"""
    
    class Meta:
        model = Refund
        fields = ('return_request', 'amount', 'method', 'notes')
    
    def validate(self, data):
        """Validate refund data"""
        return_request = data.get('return_request')
        amount = data.get('amount')
        method = data.get('method')
        
        # Validate return request exists and is processed
        if not return_request or return_request.status != 'PROCESSED':
            raise serializers.ValidationError("Return request must be processed before creating a refund.")
        
        # Validate amount
        if amount <= 0:
            raise serializers.ValidationError("Refund amount must be positive.")
        
        if amount > return_request.total_return_amount:
            raise serializers.ValidationError("Refund amount cannot exceed total return amount.")
        
        # Validate method
        valid_methods = ['CASH', 'CREDIT_NOTE', 'EXCHANGE', 'BANK_TRANSFER']
        if method not in valid_methods:
            raise serializers.ValidationError(f"Invalid refund method. Must be one of: {', '.join(valid_methods)}")
        
        return data


class RefundUpdateSerializer(RefundSerializer):
    """Serializer for updating refunds"""
    
    class Meta:
        model = Refund
        fields = ('notes',)
    
    def validate(self, data):
        """Validate update data"""
        if self.instance.status != 'PENDING':
            raise serializers.ValidationError("Refund can only be updated when status is PENDING.")
        return data


class ReturnListSerializer(serializers.ModelSerializer):
    """Serializer for listing returns"""
    
    sale_invoice_number = serializers.CharField(source='sale.invoice_number', read_only=True)
    customer_name = serializers.CharField(source='customer.name', read_only=True)
    return_items_count = serializers.SerializerMethodField()
    total_return_amount = serializers.DecimalField(max_digits=15, decimal_places=2, read_only=True)
    
    class Meta:
        model = Return
        fields = (
            'id', 'return_number', 'sale_invoice_number', 'customer_name', 'return_date',
            'status', 'reason', 'total_return_amount', 'return_items_count', 'created_at'
        )
    
    def get_return_items_count(self, obj):
        """Get count of return items"""
        return obj.return_items.count()


class RefundListSerializer(serializers.ModelSerializer):
    """Serializer for listing refunds"""
    
    return_number = serializers.CharField(source='return_request.return_number', read_only=True)
    customer_name = serializers.CharField(source='return_request.customer.name', read_only=True)
    
    class Meta:
        model = Refund
        fields = (
            'id', 'refund_number', 'return_number', 'customer_name', 'refund_date',
            'amount', 'method', 'status', 'created_at'
        )
