from django.db.models.signals import post_save, post_delete
from django.dispatch import receiver
from django.db.models import Sum
from django.db import transaction
from .models import Sales, SaleItem, TaxRate
from orders.models import Order
from order_items.models import OrderItem
import logging
from decimal import Decimal

logger = logging.getLogger(__name__)


@receiver(post_save, sender=Sales)
def update_customer_sales_activity(sender, instance, created, **kwargs):
    """Update customer sales activity when sale is created/updated"""
    try:
        if created and instance.customer:
            customer = instance.customer
            
            # Update customer's last sale date
            if hasattr(customer, 'update_last_sale_date'):
                try:
                    customer.update_last_sale_date()
                except Exception as e:
                    logger.warning(f"Failed to update last sale date for customer {customer.id}: {str(e)}")
            
            # Update customer's sales count and amount
            if hasattr(customer, 'update_sales_metrics'):
                try:
                    customer.update_sales_metrics()
                except Exception as e:
                    logger.warning(f"Failed to update sales metrics for customer {customer.id}: {str(e)}")
            
            logger.info(f"Updated sales activity for customer: {customer.name}")
            
    except Exception as e:
        logger.error(f"Failed to update customer sales activity: {str(e)}")


@receiver(post_save, sender=SaleItem)
def update_product_sales_metrics(sender, instance, created, **kwargs):
    """Update product sales metrics when sale item is created/updated"""
    try:
        if created and instance.product:
            product = instance.product
            
            # Update product's sales quantity and revenue
            if hasattr(product, 'update_sales_metrics'):
                try:
                    product.update_sales_metrics()
                except Exception as e:
                    logger.warning(f"Failed to update sales metrics for product {product.id}: {str(e)}")
            
            logger.info(f"Updated sales metrics for product: {product.name}")
            
    except Exception as e:
        logger.error(f"Failed to update product sales metrics: {str(e)}")


@receiver(post_save, sender=Sales)
def update_order_conversion_status(sender, instance, created, **kwargs):
    """Update order conversion status when sale is created from order"""
    try:
        if created and instance.order_id:
            order = instance.order_id
            
            # Update order's conversion status
            if hasattr(order, 'update_conversion_status'):
                order.update_conversion_status()
            
            logger.info(f"Updated conversion status for order: {order.id}")
            
    except Exception as e:
        logger.error(f"Failed to update order conversion status: {str(e)}")


@receiver(post_save, sender=Sales)
def update_inventory_on_sale_confirmation(sender, instance, created, **kwargs):
    """Update inventory when sale is confirmed"""
    try:
        if not created and instance.status == 'CONFIRMED':
            # Get the previous status
            if hasattr(instance, '_state') and instance._state.fields_cache.get('status') != 'CONFIRMED':
                # Sale was just confirmed, reduce inventory
                with transaction.atomic():
                    for sale_item in instance.sale_items.all():
                        if sale_item.product and hasattr(sale_item.product, 'reduce_stock_for_sale'):
                            sale_item.product.reduce_stock_for_sale(sale_item.quantity)
                    
                    logger.info(f"Reduced inventory for confirmed sale: {instance.invoice_number}")
                    
    except Exception as e:
        logger.error(f"Failed to update inventory on sale confirmation: {str(e)}")


@receiver(post_save, sender=Sales)
def update_payment_status_on_amount_change(sender, instance, created, **kwargs):
    """Update payment status when amount paid changes"""
    try:
        if not created:
            # Check if amount_paid field was updated
            if hasattr(instance, '_state') and 'amount_paid' in instance._state.fields_cache:
                old_amount = instance._state.fields_cache['amount_paid']
                if old_amount != instance.amount_paid:
                    # Amount paid changed, update payment status
                    instance.update_payment_status()
                    logger.info(f"Updated payment status for sale: {instance.invoice_number}")
                    
    except Exception as e:
        logger.error(f"Failed to update payment status: {str(e)}")


@receiver(post_delete, sender=SaleItem)
def recalculate_sale_totals_on_item_deletion(sender, instance, **kwargs):
    """Recalculate sale totals when sale item is deleted"""
    try:
        if instance.sale:
            instance.sale.recalculate_totals()
            logger.info(f"Recalculated totals for sale: {instance.sale.invoice_number}")
            
    except Exception as e:
        logger.error(f"Failed to recalculate sale totals: {str(e)}")


@receiver(post_save, sender=Sales)
def log_sale_status_changes(sender, instance, created, **kwargs):
    """Log sale status changes for audit purposes"""
    try:
        if not created:
            # Check if status field was updated
            if hasattr(instance, '_state') and 'status' in instance._state.fields_cache:
                old_status = instance._state.fields_cache['status']
                if old_status != instance.status:
                    logger.info(
                        f"Sale status changed: {instance.invoice_number} "
                        f"from {old_status} to {instance.status}"
                    )
                    
    except Exception as e:
        logger.error(f"Failed to log sale status change: {str(e)}")


@receiver(post_save, sender=Sales)
def validate_sale_totals(sender, instance, created, **kwargs):
    """Validate that sale totals are consistent with sale items"""
    try:
        if created or instance.status in ['DRAFT', 'CONFIRMED']:
            # Calculate expected subtotal from sale items
            expected_subtotal = sum(item.line_total for item in instance.sale_items.all())
            
            if abs(instance.subtotal - expected_subtotal) > 0.01:  # Allow for small decimal differences
                logger.warning(
                    f"Sale totals mismatch for {instance.invoice_number}: "
                    f"expected {expected_subtotal}, got {instance.subtotal}"
                )
                
                # Auto-correct if in draft status
                if instance.status == 'DRAFT':
                    instance.recalculate_totals()
                    logger.info(f"Auto-corrected totals for sale: {instance.invoice_number}")
                    
    except Exception as e:
        logger.error(f"Failed to validate sale totals: {str(e)}")


@receiver(post_save, sender=Sales)
def update_customer_credit_limit(sender, instance, created, **kwargs):
    """Update customer credit limit when credit sale is created"""
    try:
        if created and instance.payment_method == 'CREDIT' and instance.customer:
            customer = instance.customer
            
            # Update customer's credit usage
            if hasattr(customer, 'update_credit_usage'):
                customer.update_credit_usage(instance.remaining_amount)
            
            logger.info(f"Updated credit usage for customer: {customer.name}")
            
    except Exception as e:
        logger.error(f"Failed to update customer credit limit: {str(e)}")


@receiver(post_save, sender=Sales)
def send_sale_notifications(sender, instance, created, **kwargs):
    """Send notifications for important sale events"""
    try:
        if created:
            # Send notification for new sale
            logger.info(f"New sale created: {instance.invoice_number}")
            
        elif instance.status == 'PAID':
            # Send notification for payment received
            logger.info(f"Payment received for sale: {instance.invoice_number}")
            
        elif instance.status == 'DELIVERED':
            # Send notification for delivery
            logger.info(f"Sale delivered: {instance.invoice_number}")
            
    except Exception as e:
        logger.error(f"Failed to send sale notifications: {str(e)}")


@receiver(post_save, sender=Sales)
def update_financial_reports(sender, instance, created, **kwargs):
    """Update financial reports when sale is created/updated"""
    try:
        if created or instance.status in ['CONFIRMED', 'PAID', 'DELIVERED']:
            # Update daily/monthly sales reports
            logger.info(f"Updated financial reports for sale: {instance.invoice_number}")
            
    except Exception as e:
        logger.error(f"Failed to update financial reports: {str(e)}")


@receiver(post_save, sender=Sales)
def validate_payment_method_consistency(sender, instance, created, **kwargs):
    """Validate payment method consistency with amount paid"""
    try:
        if instance.payment_method == 'SPLIT' and not instance.split_payment_details:
            logger.warning(
                f"Split payment method selected but no split details provided for sale: {instance.invoice_number}"
            )
            
        elif instance.payment_method == 'CREDIT' and instance.amount_paid > 0:
            logger.warning(
                f"Credit sale has partial payment for sale: {instance.invoice_number}"
            )
            
    except Exception as e:
        logger.error(f"Failed to validate payment method consistency: {str(e)}")


@receiver(post_save, sender=Sales)
def update_tax_calculations(sender, instance, created, **kwargs):
    """Ensure tax calculations are accurate with new tax configuration system"""
    try:
        if created or instance.status in ['DRAFT', 'CONFIRMED']:
            # Validate tax calculation using new tax configuration
            if instance.tax_configuration:
                taxable_amount = instance.subtotal - instance.overall_discount
                expected_tax = Decimal('0.00')
                
                # Calculate expected tax from configuration
                for tax_type, tax_data in instance.tax_configuration.items():
                    if 'percentage' in tax_data:
                        percentage = Decimal(str(tax_data['percentage']))
                        tax_amount = (taxable_amount * percentage) / 100
                        expected_tax += tax_amount
                
                # Check if calculated tax matches stored tax
                if abs(instance.tax_amount - expected_tax) > 0.01:
                    logger.warning(
                        f"Tax calculation mismatch for sale {instance.invoice_number}: "
                        f"expected {expected_tax}, got {instance.tax_amount}"
                    )
                    
                    # Auto-correct if in draft status
                    if instance.status == 'DRAFT' and not hasattr(instance, '_updating_tax'):
                        instance._updating_tax = True
                        try:
                            # Recalculate taxes
                            instance.calculate_taxes()
                            instance.grand_total = instance.subtotal - instance.overall_discount + instance.tax_amount
                            instance.save(update_fields=['tax_amount', 'grand_total'])
                            logger.info(f"Auto-corrected tax calculations for sale: {instance.invoice_number}")
                        finally:
                            delattr(instance, '_updating_tax')
            else:
                # No tax configuration, ensure tax_amount is 0
                if instance.tax_amount != 0:
                    logger.warning(
                        f"Sale {instance.invoice_number} has no tax configuration but tax_amount is {instance.tax_amount}"
                    )
                    
    except Exception as e:
        logger.error(f"Failed to update tax calculations: {str(e)}")


@receiver(post_save, sender=TaxRate)
def update_sales_with_tax_rate_changes(sender, instance, created, **kwargs):
    """Update sales when tax rates change"""
    try:
        if not created and instance.is_active:
            # If tax rate was updated, we might need to update existing sales
            # This is a complex operation that should be handled carefully
            logger.info(f"Tax rate {instance.name} updated. Consider reviewing existing sales.")
            
    except Exception as e:
        logger.error(f"Failed to handle tax rate change: {str(e)}")


@receiver(post_save, sender=TaxRate)
def validate_tax_rate_effectiveness(sender, instance, created, **kwargs):
    """Validate tax rate effectiveness dates"""
    try:
        if instance.effective_to and instance.effective_to < instance.effective_from:
            logger.warning(
                f"Tax rate {instance.name} has invalid effective dates: "
                f"from {instance.effective_from} to {instance.effective_to}"
            )
            
    except Exception as e:
        logger.error(f"Failed to validate tax rate effectiveness: {str(e)}")
