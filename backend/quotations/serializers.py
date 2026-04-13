from rest_framework import serializers
from .models import Quotation, QuotationItem
from customers.models import Customer
from products.models import Product

class QuotationItemSerializer(serializers.ModelSerializer):
    class Meta:
        model = QuotationItem
        fields = '__all__'
        read_only_fields = ('id', 'product_name', 'line_total', 'created_at', 'updated_at')

class QuotationItemCreateUpdateSerializer(serializers.ModelSerializer):
    id = serializers.UUIDField(required=False)
    
    class Meta:
        model = QuotationItem
        fields = ('id', 'product', 'quantity', 'unit_price')

class QuotationSerializer(serializers.ModelSerializer):
    items = QuotationItemSerializer(many=True, read_only=True)
    created_by_name = serializers.StringRelatedField(source='created_by', read_only=True)
    
    class Meta:
        model = Quotation
        fields = '__all__'
        read_only_fields = (
            'id', 'customer_name', 'customer_phone', 'customer_email',
            'base_amount', 'grand_total', 'conversion_status',
            'created_at', 'updated_at', 'created_by'
        )

class QuotationCreateSerializer(serializers.ModelSerializer):
    items = QuotationItemCreateUpdateSerializer(many=True)
    
    class Meta:
        model = Quotation
        fields = (
            'customer', 'quotation_number', 'discount_amount', 'tax_amount', 
            'date_issued', 'expiry_date', 'description', 
            'terms_conditions', 'items'
        )
        
    def create(self, validated_data):
        items_data = validated_data.pop('items', [])
        user = self.context['request'].user
        validated_data['created_by'] = user
        
        quotation = Quotation.objects.create(**validated_data)
        
        for item_data in items_data:
            QuotationItem.objects.create(quotation=quotation, **item_data)
            
        quotation.calculate_totals()
        return quotation

class QuotationUpdateSerializer(serializers.ModelSerializer):
    items = QuotationItemCreateUpdateSerializer(many=True, required=False)
    
    class Meta:
        model = Quotation
        fields = (
            'status', 'quotation_number', 'discount_amount', 'tax_amount', 
            'expiry_date', 'description', 'terms_conditions', 'items'
        )
        
    def update(self, instance, validated_data):
        items_data = validated_data.pop('items', None)
        
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        instance.save()
        
        if items_data is not None:
            # Simple handling: Delete existing and recreate
            instance.items.all().delete()
            for item_data in items_data:
                # Remove ID if provided for recreation
                item_data.pop('id', None)
                QuotationItem.objects.create(quotation=instance, **item_data)
                
        instance.calculate_totals()
        return instance
