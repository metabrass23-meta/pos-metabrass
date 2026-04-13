import uuid
from django.db import models
from django.conf import settings
from django.core.exceptions import ValidationError
from django.utils import timezone
from decimal import Decimal
from datetime import timedelta, date


class Quotation(models.Model):
    """Quotation/Estimate model"""
    
    STATUS_CHOICES = [
        ('PENDING', 'Pending'),
        ('ACCEPTED', 'Accepted'),
        ('REJECTED', 'Rejected'),
        ('EXPIRED', 'Expired'),
    ]
    
    id = models.UUIDField(
        primary_key=True,
        default=uuid.uuid4,
        editable=False
    )
    customer = models.ForeignKey(
        'customers.Customer',
        on_delete=models.PROTECT,
        related_name='quotations',
        help_text="Customer requesting the quotation"
    )
    customer_name = models.CharField(max_length=200, help_text="Cached customer name")
    customer_phone = models.CharField(max_length=20, help_text="Cached customer phone")
    customer_email = models.EmailField(blank=True, help_text="Cached customer email")
    quotation_number = models.CharField(max_length=100, blank=True, null=True, help_text="Custom quotation number")
    
    base_amount = models.DecimalField(
        max_digits=15, decimal_places=2, default=Decimal('0.00'),
        help_text="Total before discount and tax"
    )
    discount_amount = models.DecimalField(
        max_digits=15, decimal_places=2, default=Decimal('0.00'),
        help_text="Discount applied"
    )
    tax_amount = models.DecimalField(
        max_digits=15, decimal_places=2, default=Decimal('0.00'),
        help_text="Tax applied"
    )
    grand_total = models.DecimalField(
        max_digits=15, decimal_places=2, default=Decimal('0.00'),
        help_text="Final quotation amount"
    )
    
    date_issued = models.DateField(default=timezone.now, help_text="Date when quotation was created")
    expiry_date = models.DateField(help_text="When this quotation expires")
    
    description = models.TextField(blank=True, help_text="General notes")
    terms_conditions = models.TextField(blank=True, help_text="Terms and conditions")
    
    status = models.CharField(
        max_length=20, choices=STATUS_CHOICES, default='PENDING', help_text="Current status"
    )
    is_active = models.BooleanField(default=True, help_text="Used for soft deletion")
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    created_by = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True, blank=True,
        related_name='created_quotations'
    )

    conversion_status = models.CharField(
        max_length=20,
        choices=[
            ('NOT_CONVERTED', 'Not Converted'),
            ('CONVERTED_TO_SALE', 'Converted to Sale'),
            ('CONVERTED_TO_ORDER', 'Converted to Order'),
        ],
        default='NOT_CONVERTED'
    )

    class Meta:
        db_table = 'quotation'
        verbose_name = 'Quotation'
        verbose_name_plural = 'Quotations'
        ordering = ['-date_issued', '-created_at']

    def __str__(self):
        return f"Quotation #{self.id} - {self.customer_name}"

    def save(self, *args, **kwargs):
        if self.customer and not self.customer_name:
            self.customer_name = self.customer.name
            self.customer_phone = self.customer.phone
            self.customer_email = self.customer.email or ''
            
        if not self.expiry_date:
            self.expiry_date = timezone.now().date() + timedelta(days=14)
            
        self.grand_total = self.base_amount - self.discount_amount + self.tax_amount
        super().save(*args, **kwargs)

    def calculate_totals(self):
        total = self.items.filter(is_active=True).aggregate(
            total=models.Sum('line_total')
        )['total'] or Decimal('0.00')
        self.base_amount = total
        self.save()


class QuotationItem(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    quotation = models.ForeignKey(
        Quotation, on_delete=models.CASCADE, related_name='items'
    )
    product = models.ForeignKey(
        'products.Product', on_delete=models.PROTECT, related_name='quotation_items'
    )
    product_name = models.CharField(max_length=200)
    quantity = models.PositiveIntegerField()
    unit_price = models.DecimalField(max_digits=12, decimal_places=2)
    line_total = models.DecimalField(max_digits=15, decimal_places=2)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'quotation_item'
        verbose_name = 'Quotation Item'
        verbose_name_plural = 'Quotation Items'
        ordering = ['created_at']

    def __str__(self):
        return f"{self.product_name} x{self.quantity}"

    def save(self, *args, **kwargs):
        if self.product and not self.product_name:
            self.product_name = self.product.name
        if self.product and not self.unit_price:
            self.unit_price = self.product.price
            
        self.line_total = self.quantity * self.unit_price
        super().save(*args, **kwargs)
