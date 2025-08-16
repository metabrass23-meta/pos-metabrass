import uuid
from django.db import models
from django.conf import settings
from django.core.exceptions import ValidationError
from django.utils import timezone
from decimal import Decimal
from datetime import date


def generate_invoice_number():
    """Generate sequential invoice number in format: INV-YYYY-XXXX"""
    today = date.today()
    year = today.year
    
    # Get the last invoice number for this year
    last_invoice = Sales.objects.filter(
        invoice_number__startswith=f'INV-{year}-'
    ).order_by('-invoice_number').first()
    
    if last_invoice:
        try:
            # Extract the sequence number and increment
            last_sequence = int(last_invoice.invoice_number.split('-')[-1])
            new_sequence = last_sequence + 1
        except (ValueError, IndexError):
            new_sequence = 1
    else:
        new_sequence = 1
    
    return f'INV-{year}-{new_sequence:04d}'


class SalesQuerySet(models.QuerySet):
    """Custom QuerySet for Sales model"""
    
    def active(self):
        """Get active sales"""
        return self.filter(is_active=True)
    
    def by_status(self, status):
        """Get sales by status"""
        return self.filter(status=status.upper())
    
    def by_customer(self, customer_id):
        """Get sales for a specific customer"""
        return self.filter(customer_id=customer_id)
    
    def by_date_range(self, start_date, end_date):
        """Get sales within date range"""
        return self.filter(date_of_sale__date__range=[start_date, end_date])
    
    def by_payment_method(self, payment_method):
        """Get sales by payment method"""
        return self.filter(payment_method=payment_method.upper())
    
    def paid(self):
        """Get fully paid sales"""
        return self.filter(is_fully_paid=True)
    
    def unpaid(self):
        """Get unpaid or partially paid sales"""
        return self.filter(is_fully_paid=False)
    
    def recent(self, days=30):
        """Get sales from last N days"""
        cutoff_date = timezone.now() - timezone.timedelta(days=days)
        return self.filter(date_of_sale__gte=cutoff_date)
    
    def today(self):
        """Get today's sales"""
        today = date.today()
        return self.filter(date_of_sale__date=today)
    
    def this_month(self):
        """Get this month's sales"""
        today = date.today()
        return self.filter(
            date_of_sale__year=today.year,
            date_of_sale__month=today.month
        )
    
    def this_year(self):
        """Get this year's sales"""
        return self.filter(date_of_sale__year=date.today().year)
    
    def search(self, query):
        """Search sales by invoice number, customer name, phone, or notes"""
        return self.filter(
            models.Q(invoice_number__icontains=query) |
            models.Q(customer_name__icontains=query) |
            models.Q(customer_phone__icontains=query) |
            models.Q(customer_email__icontains=query) |
            models.Q(notes__icontains=query)
        )
    
    def by_order(self, order_id):
        """Get sales created from a specific order"""
        return self.filter(order_id=order_id)


class Sales(models.Model):
    """Sales model for managing complete sales transactions"""
    
    # Sale Status Choices
    STATUS_CHOICES = [
        ('DRAFT', 'Draft'),
        ('CONFIRMED', 'Confirmed'),
        ('INVOICED', 'Invoiced'),
        ('PAID', 'Paid'),
        ('DELIVERED', 'Delivered'),
        ('CANCELLED', 'Cancelled'),
        ('RETURNED', 'Returned'),
    ]
    
    # Payment Method Choices
    PAYMENT_METHOD_CHOICES = [
        ('CASH', 'Cash'),
        ('CARD', 'Credit/Debit Card'),
        ('BANK_TRANSFER', 'Bank Transfer'),
        ('MOBILE_PAYMENT', 'Mobile Payment (JazzCash/EasyPaisa)'),
        ('SPLIT', 'Split Payment'),
        ('CREDIT', 'Credit Sale'),
    ]
    
    # Primary fields
    id = models.UUIDField(
        primary_key=True,
        default=uuid.uuid4,
        editable=False
    )
    invoice_number = models.CharField(
        max_length=20,
        unique=True,
        default=generate_invoice_number,
        help_text="Auto-generated invoice number"
    )
    order_id = models.ForeignKey(
        'orders.Order',
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='sales',
        help_text="Optional: Order this sale was created from"
    )
    customer = models.ForeignKey(
        'customers.Customer',
        on_delete=models.PROTECT,
        related_name='sales',
        help_text="Customer making the purchase"
    )
    
    # Cached customer information for historical accuracy
    customer_name = models.CharField(
        max_length=200,
        help_text="Cached customer name at time of sale"
    )
    customer_phone = models.CharField(
        max_length=20,
        help_text="Cached customer contact at time of sale"
    )
    customer_email = models.EmailField(
        blank=True,
        help_text="Cached customer email at time of sale"
    )
    
    # Financial fields
    subtotal = models.DecimalField(
        max_digits=15,
        decimal_places=2,
        default=Decimal('0.00'),
        help_text="Sum of all line items before discounts"
    )
    overall_discount = models.DecimalField(
        max_digits=12,
        decimal_places=2,
        default=Decimal('0.00'),
        help_text="Total discount applied to entire sale"
    )
    gst_percentage = models.DecimalField(
        max_digits=5,
        decimal_places=2,
        default=Decimal('17.00'),
        help_text="GST tax rate (default 17% for Pakistan)"
    )
    tax_amount = models.DecimalField(
        max_digits=12,
        decimal_places=2,
        default=Decimal('0.00'),
        help_text="Calculated GST amount"
    )
    grand_total = models.DecimalField(
        max_digits=15,
        decimal_places=2,
        default=Decimal('0.00'),
        help_text="Final amount after discounts and taxes"
    )
    amount_paid = models.DecimalField(
        max_digits=15,
        decimal_places=2,
        default=Decimal('0.00'),
        help_text="Total amount received from customer"
    )
    remaining_amount = models.DecimalField(
        max_digits=15,
        decimal_places=2,
        default=Decimal('0.00'),
        help_text="Outstanding balance"
    )
    is_fully_paid = models.BooleanField(
        default=False,
        help_text="Payment completion status"
    )
    
    # Payment details
    payment_method = models.CharField(
        max_length=20,
        choices=PAYMENT_METHOD_CHOICES,
        default='CASH',
        help_text="Method of payment"
    )
    split_payment_details = models.JSONField(
        default=dict,
        blank=True,
        help_text="Details for multiple payment methods when payment_method='Split'"
    )
    
    # Sale details
    date_of_sale = models.DateTimeField(
        default=timezone.now,
        help_text="Transaction timestamp"
    )
    status = models.CharField(
        max_length=20,
        choices=STATUS_CHOICES,
        default='DRAFT',
        help_text="Current sale status"
    )
    notes = models.TextField(
        blank=True,
        help_text="Additional sale information or special instructions"
    )
    
    # System fields
    is_active = models.BooleanField(
        default=True,
        help_text="Used for soft deletion"
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    created_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='created_sales',
        help_text="Sales person who processed the transaction"
    )
    
    objects = SalesQuerySet.as_manager()
    
    class Meta:
        db_table = 'sales'
        verbose_name = 'Sale'
        verbose_name_plural = 'Sales'
        ordering = ['-date_of_sale', '-created_at']
        indexes = [
            models.Index(fields=['invoice_number']),
            models.Index(fields=['customer']),
            models.Index(fields=['order_id']),
            models.Index(fields=['status']),
            models.Index(fields=['payment_method']),
            models.Index(fields=['date_of_sale']),
            models.Index(fields=['is_fully_paid']),
            models.Index(fields=['is_active']),
            models.Index(fields=['created_at']),
        ]
    
    def __str__(self):
        return f"{self.invoice_number} - {self.customer_name} ({self.get_status_display()})"
    
    def clean(self):
        """Validate model data"""
        if self.subtotal < 0:
            raise ValidationError({'subtotal': 'Subtotal cannot be negative.'})
        
        if self.overall_discount < 0:
            raise ValidationError({'overall_discount': 'Discount cannot be negative.'})
        
        if self.overall_discount > self.subtotal:
            raise ValidationError({'overall_discount': 'Discount cannot exceed subtotal.'})
        
        if self.gst_percentage < 0 or self.gst_percentage > 100:
            raise ValidationError({'gst_percentage': 'GST percentage must be between 0 and 100.'})
        
        if self.amount_paid < 0:
            raise ValidationError({'amount_paid': 'Amount paid cannot be negative.'})
        
        if self.amount_paid > self.grand_total:
            raise ValidationError({'amount_paid': 'Amount paid cannot exceed grand total.'})
        
        # Validate split payment details
        if self.payment_method == 'SPLIT' and not self.split_payment_details:
            raise ValidationError({'split_payment_details': 'Split payment details are required when payment method is Split.'})
    
    def save(self, *args, **kwargs):
        """Auto-calculate financial fields and validate before saving"""
        # Cache customer information if not set
        if self.customer and not self.customer_name:
            self.customer_name = self.customer.name
        
        if self.customer and not self.customer_phone:
            self.customer_phone = self.customer.phone
        
        if self.customer and not self.customer_email:
            self.customer_email = self.customer.email
        
        # Calculate tax amount
        if self.subtotal and self.overall_discount and self.gst_percentage:
            taxable_amount = self.subtotal - self.overall_discount
            self.tax_amount = (taxable_amount * self.gst_percentage) / 100
        
        # Calculate grand total
        if self.subtotal and self.overall_discount and self.tax_amount:
            self.grand_total = self.subtotal - self.overall_discount + self.tax_amount
        
        # Calculate remaining amount
        if self.grand_total and self.amount_paid:
            self.remaining_amount = self.grand_total - self.amount_paid
        
        # Update payment status
        if self.grand_total and self.amount_paid:
            self.is_fully_paid = self.amount_paid >= self.grand_total
        
        self.full_clean()
        super().save(*args, **kwargs)
    
    @property
    def sales_age_days(self):
        """Days since sale was created"""
        return (timezone.now().date() - self.date_of_sale.date()).days
    
    @property
    def formatted_grand_total(self):
        """Currency formatted grand total (PKR format)"""
        return f"PKR {self.grand_total:,.2f}"
    
    @property
    def formatted_remaining_amount(self):
        """Currency formatted outstanding balance"""
        return f"PKR {self.remaining_amount:,.2f}"
    
    @property
    def payment_percentage(self):
        """Percentage of payment completed"""
        if self.grand_total > 0:
            return (self.amount_paid / self.grand_total) * 100
        return 0
    
    @property
    def sales_summary(self):
        """Short summary for display purposes"""
        return f"{self.invoice_number} - {self.customer_name} - {self.formatted_grand_total}"
    
    @property
    def authorized_initials(self):
        """Initials of sales person who created the sale"""
        if self.created_by:
            return ''.join([name[0].upper() for name in self.created_by.full_name.split()])
        return ''
    
    @property
    def invoice_display(self):
        """Formatted invoice number for display"""
        return f"#{self.invoice_number}"
    
    @property
    def payment_status_display(self):
        """Human readable payment status"""
        if self.is_fully_paid:
            return "Fully Paid"
        elif self.amount_paid > 0:
            return f"Partially Paid ({self.payment_percentage:.1f}%)"
        else:
            return "Unpaid"
    
    @property
    def total_items(self):
        """Count of items in this sale"""
        return self.sale_items.count()
    
    @property
    def profit_margin(self):
        """Calculated profit from this sale (if cost data available)"""
        # This would need to be implemented based on product cost data
        # For now, return None
        return None
    
    @property
    def tax_breakdown(self):
        """Detailed tax calculation breakdown"""
        taxable_amount = self.subtotal - self.overall_discount
        return {
            'taxable_amount': taxable_amount,
            'gst_percentage': self.gst_percentage,
            'gst_amount': self.tax_amount,
            'tax_rate_display': f"{self.gst_percentage}%"
        }
    
    def can_be_cancelled(self):
        """Check if sale can be cancelled"""
        return self.status in ['DRAFT', 'CONFIRMED', 'INVOICED']
    
    def can_be_returned(self):
        """Check if sale can be returned"""
        return self.status == 'DELIVERED' and self.is_fully_paid
    
    def update_payment_status(self):
        """Update payment status based on amount paid"""
        if self.grand_total > 0:
            self.is_fully_paid = self.amount_paid >= self.grand_total
            self.remaining_amount = max(0, self.grand_total - self.amount_paid)
            self.save(update_fields=['is_fully_paid', 'remaining_amount'])
    
    def recalculate_totals(self):
        """Recalculate all financial totals from sale items"""
        total_subtotal = sum(item.line_total for item in self.sale_items.all())
        self.subtotal = total_subtotal
        
        # Recalculate tax and grand total
        taxable_amount = self.subtotal - self.overall_discount
        self.tax_amount = (taxable_amount * self.gst_percentage) / 100
        self.grand_total = self.subtotal - self.overall_discount + self.tax_amount
        
        # Update payment status
        self.update_payment_status()
        self.save(update_fields=['subtotal', 'tax_amount', 'grand_total'])


class SaleItemQuerySet(models.QuerySet):
    """Custom QuerySet for SaleItem model"""
    
    def active(self):
        """Get active sale items"""
        return self.filter(is_active=True)
    
    def by_sale(self, sale_id):
        """Get items for a specific sale"""
        return self.filter(sale_id=sale_id)
    
    def by_product(self, product_id):
        """Get sale items for a specific product"""
        return self.filter(product_id=product_id)
    
    def by_order_item(self, order_item_id):
        """Get sale items created from a specific order item"""
        return self.filter(order_item=order_item_id)
    
    def search(self, query):
        """Search sale items by product name or customization notes"""
        return self.filter(
            models.Q(product_name__icontains=query) |
            models.Q(customization_notes__icontains=query)
        )


class SaleItem(models.Model):
    """Sale Item model for managing individual products within sales"""
    
    id = models.UUIDField(
        primary_key=True,
        default=uuid.uuid4,
        editable=False
    )
    sale = models.ForeignKey(
        Sales,
        on_delete=models.CASCADE,
        related_name='sale_items',
        help_text="Parent sale transaction"
    )
    # order_item = models.ForeignKey(
    #     'order_items.OrderItem',
    #     on_delete=models.SET_NULL,
    #     null=True,
    #     blank=True,
    #     related_name='sale_items',
    #     help_text="Optional: Order item this sale item was created from",
    #     to_field='id'
    # )
    order_item = models.UUIDField(
        null=True,
        blank=True,
        help_text="Optional: Order item ID this sale item was created from"
    )
    product = models.ForeignKey(
        'products.Product',
        on_delete=models.PROTECT,
        related_name='sale_items',
        help_text="Sold product reference"
    )
    product_name = models.CharField(
        max_length=200,
        help_text="Cached product name at time of sale"
    )
    unit_price = models.DecimalField(
        max_digits=12,
        decimal_places=2,
        help_text="Selling price per unit at time of sale"
    )
    quantity = models.PositiveIntegerField(
        help_text="Number of units sold"
    )
    item_discount = models.DecimalField(
        max_digits=12,
        decimal_places=2,
        default=Decimal('0.00'),
        help_text="Discount applied to this specific item"
    )
    line_total = models.DecimalField(
        max_digits=15,
        decimal_places=2,
        help_text="Total for this line after discount"
    )
    customization_notes = models.TextField(
        blank=True,
        help_text="Inherited from order item or new customizations"
    )
    is_active = models.BooleanField(
        default=True,
        help_text="Used for soft deletion"
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    objects = SaleItemQuerySet.as_manager()
    
    class Meta:
        db_table = 'sale_item'
        verbose_name = 'Sale Item'
        verbose_name_plural = 'Sale Items'
        ordering = ['sale', 'created_at']
        indexes = [
            models.Index(fields=['sale']),
            models.Index(fields=['order_item']),
            models.Index(fields=['product']),
            models.Index(fields=['is_active']),
            models.Index(fields=['created_at']),
        ]
    
    def __str__(self):
        return f"{self.product_name} x{self.quantity} in {self.sale.invoice_number}"
    
    def clean(self):
        """Validate model data"""
        if self.quantity <= 0:
            raise ValidationError({'quantity': 'Quantity must be greater than zero.'})
        
        if self.unit_price < 0:
            raise ValidationError({'unit_price': 'Unit price cannot be negative.'})
        
        if self.item_discount < 0:
            raise ValidationError({'item_discount': 'Item discount cannot be negative.'})
        
        # Validate line total calculation
        if self.quantity and self.unit_price:
            expected_total = self.quantity * self.unit_price - self.item_discount
            if self.line_total != expected_total:
                self.line_total = expected_total
    
    def save(self, *args, **kwargs):
        """Auto-populate fields and calculate totals before saving"""
        # Auto-populate product name and unit price from product if not set
        if self.product and not self.product_name:
            self.product_name = self.product.name
        
        if self.product and not self.unit_price:
            self.unit_price = self.product.price
        
        # Calculate line total
        if self.quantity and self.unit_price:
            self.line_total = (self.quantity * self.unit_price) - self.item_discount
        
        self.full_clean()
        super().save(*args, **kwargs)
    
    @property
    def discounted_unit_price(self):
        """Unit price after item-specific discount"""
        if self.quantity > 0:
            return self.line_total / self.quantity
        return self.unit_price
    
    @property
    def total_before_discount(self):
        """Line total before any discounts applied"""
        return self.quantity * self.unit_price
    
    @property
    def discount_percentage(self):
        """Percentage discount applied to this item"""
        if self.total_before_discount > 0:
            return (self.item_discount / self.total_before_discount) * 100
        return 0
    
    @property
    def item_profit(self):
        """Profit margin for this specific item"""
        # This would need to be implemented based on product cost data
        # For now, return None
        return None
    
    @property
    def formatted_line_total(self):
        """Currency formatted line total"""
        return f"PKR {self.line_total:,.2f}"
    
    @property
    def product_info_at_sale(self):
        """Product details captured at time of sale"""
        return {
            'name': self.product_name,
            'unit_price': self.unit_price,
            'quantity': self.quantity,
            'customization_notes': self.customization_notes
        }
