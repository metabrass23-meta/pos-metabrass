# Generated manually for Sales app

import django.db.models.deletion
import django.utils.timezone
import uuid
from decimal import Decimal
from django.conf import settings
from django.db import migrations, models


class Migration(migrations.Migration):

    initial = True

    dependencies = [
        ('customers', '0001_initial'),
        ('orders', '0001_initial'),
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
    ]

    operations = [
        migrations.CreateModel(
            name='Sales',
            fields=[
                ('id', models.UUIDField(default=uuid.uuid4, editable=False, primary_key=True, serialize=False)),
                ('invoice_number', models.CharField(help_text='Auto-generated invoice number', max_length=20, unique=True)),
                ('customer_name', models.CharField(help_text='Cached customer name at time of sale', max_length=200)),
                ('customer_phone', models.CharField(help_text='Cached customer contact at time of sale', max_length=20)),
                ('customer_email', models.EmailField(blank=True, help_text='Cached customer email at time of sale', max_length=254)),
                ('subtotal', models.DecimalField(decimal_places=2, default=Decimal('0.00'), help_text='Sum of all line items before discounts', max_digits=15)),
                ('overall_discount', models.DecimalField(decimal_places=2, default=Decimal('0.00'), help_text='Total discount applied to entire sale', max_digits=12)),
                ('gst_percentage', models.DecimalField(decimal_places=2, default=Decimal('17.00'), help_text='GST tax rate (default 17% for Pakistan)', max_digits=5)),
                ('tax_amount', models.DecimalField(decimal_places=2, default=Decimal('0.00'), help_text='Calculated GST amount', max_digits=12)),
                ('grand_total', models.DecimalField(decimal_places=2, default=Decimal('0.00'), help_text='Final amount after discounts and taxes', max_digits=15)),
                ('amount_paid', models.DecimalField(decimal_places=2, default=Decimal('0.00'), help_text='Total amount received from customer', max_digits=15)),
                ('remaining_amount', models.DecimalField(decimal_places=2, default=Decimal('0.00'), help_text='Outstanding balance', max_digits=15)),
                ('is_fully_paid', models.BooleanField(default=False, help_text='Payment completion status')),
                ('payment_method', models.CharField(choices=[('CASH', 'Cash'), ('CARD', 'Credit/Debit Card'), ('BANK_TRANSFER', 'Bank Transfer'), ('MOBILE_PAYMENT', 'Mobile Payment (JazzCash/EasyPaisa)'), ('SPLIT', 'Split Payment'), ('CREDIT', 'Credit Sale')], default='CASH', help_text='Method of payment', max_length=20)),
                ('split_payment_details', models.JSONField(blank=True, default=dict, help_text='Details for multiple payment methods when payment_method=Split')),
                ('date_of_sale', models.DateTimeField(default=django.utils.timezone.now, help_text='Transaction timestamp')),
                ('status', models.CharField(choices=[('DRAFT', 'Draft'), ('CONFIRMED', 'Confirmed'), ('INVOICED', 'Invoiced'), ('PAID', 'Paid'), ('DELIVERED', 'Delivered'), ('CANCELLED', 'Cancelled'), ('RETURNED', 'Returned')], default='DRAFT', help_text='Current sale status', max_length=20)),
                ('notes', models.TextField(blank=True, help_text='Additional sale information or special instructions')),
                ('is_active', models.BooleanField(default=True, help_text='Used for soft deletion')),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('updated_at', models.DateTimeField(auto_now=True)),
                ('customer', models.ForeignKey(help_text='Customer making the purchase', on_delete=django.db.models.deletion.PROTECT, related_name='sales', to='customers.customer')),
                ('created_by', models.ForeignKey(blank=True, help_text='Sales person who processed the transaction', null=True, on_delete=django.db.models.deletion.SET_NULL, related_name='created_sales', to=settings.AUTH_USER_MODEL)),
                ('order_id', models.ForeignKey(blank=True, help_text='Optional: Order this sale was created from', null=True, on_delete=django.db.models.deletion.SET_NULL, related_name='sales', to='orders.order')),
            ],
            options={
                'verbose_name': 'Sale',
                'verbose_name_plural': 'Sales',
                'db_table': 'sales',
                'ordering': ['-date_of_sale', '-created_at'],
            },
        ),
        migrations.CreateModel(
            name='SaleItem',
            fields=[
                ('id', models.UUIDField(default=uuid.uuid4, editable=False, primary_key=True, serialize=False)),
                ('product_name', models.CharField(help_text='Cached product name at time of sale', max_length=200)),
                ('unit_price', models.DecimalField(decimal_places=2, help_text='Selling price per unit at time of sale', max_digits=12)),
                ('quantity', models.PositiveIntegerField(help_text='Number of units sold')),
                ('item_discount', models.DecimalField(decimal_places=2, default=Decimal('0.00'), help_text='Discount applied to this specific item', max_digits=12)),
                ('line_total', models.DecimalField(decimal_places=2, help_text='Total for this line after discount', max_digits=15)),
                ('customization_notes', models.TextField(blank=True, help_text='Inherited from order item or new customizations')),
                ('is_active', models.BooleanField(default=True, help_text='Used for soft deletion')),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('updated_at', models.DateTimeField(auto_now=True)),
                ('order_item', models.ForeignKey(blank=True, help_text='Optional: Order item this sale item was created from', null=True, on_delete=django.db.models.deletion.SET_NULL, related_name='sale_items', to='orders.orderitem')),
                ('product', models.ForeignKey(help_text='Sold product reference', on_delete=django.db.models.deletion.PROTECT, related_name='sale_items', to='products.product')),
                ('sale', models.ForeignKey(help_text='Parent sale transaction', on_delete=django.db.models.deletion.CASCADE, related_name='sale_items', to='sales.sales')),
            ],
            options={
                'verbose_name': 'Sale Item',
                'verbose_name_plural': 'Sale Items',
                'db_table': 'sale_item',
                'ordering': ['sale', 'created_at'],
            },
        ),
        migrations.AddIndex(
            model_name='sales',
            index=models.Index(fields=['invoice_number'], name='sales_invoice_number_idx'),
        ),
        migrations.AddIndex(
            model_name='sales',
            index=models.Index(fields=['customer'], name='sales_customer_idx'),
        ),
        migrations.AddIndex(
            model_name='sales',
            index=models.Index(fields=['order_id'], name='sales_order_id_idx'),
        ),
        migrations.AddIndex(
            model_name='sales',
            index=models.Index(fields=['status'], name='sales_status_idx'),
        ),
        migrations.AddIndex(
            model_name='sales',
            index=models.Index(fields=['payment_method'], name='sales_payment_method_idx'),
        ),
        migrations.AddIndex(
            model_name='sales',
            index=models.Index(fields=['date_of_sale'], name='sales_date_of_sale_idx'),
        ),
        migrations.AddIndex(
            model_name='sales',
            index=models.Index(fields=['is_fully_paid'], name='sales_is_fully_paid_idx'),
        ),
        migrations.AddIndex(
            model_name='sales',
            index=models.Index(fields=['is_active'], name='sales_is_active_idx'),
        ),
        migrations.AddIndex(
            model_name='sales',
            index=models.Index(fields=['created_at'], name='sales_created_at_idx'),
        ),
        migrations.AddIndex(
            model_name='saleitem',
            index=models.Index(fields=['sale'], name='sale_item_sale_idx'),
        ),
        migrations.AddIndex(
            model_name='saleitem',
            index=models.Index(fields=['order_item'], name='sale_item_order_item_idx'),
        ),
        migrations.AddIndex(
            model_name='saleitem',
            index=models.Index(fields=['product'], name='sale_item_product_idx'),
        ),
        migrations.AddIndex(
            model_name='saleitem',
            index=models.Index(fields=['is_active'], name='sale_item_is_active_idx'),
        ),
        migrations.AddIndex(
            model_name='saleitem',
            index=models.Index(fields=['created_at'], name='sale_item_created_at_idx'),
        ),
    ]
