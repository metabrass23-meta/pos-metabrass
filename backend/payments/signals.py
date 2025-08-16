from django.db.models.signals import post_save, post_delete
from django.dispatch import receiver
from django.utils import timezone
from .models import Payment
import logging

# Set up logger
logger = logging.getLogger(__name__)


@receiver(post_save, sender=Payment)
def payment_post_save(sender, instance, created, **kwargs):
    """
    Signal handler for payment post-save operations
    """
    try:
        if created:
            # Log payment creation
            logger.info(
                f"New payment created: {instance.id} - "
                f"Amount: {instance.amount_paid}, "
                f"Payer: {instance.payer_type}, "
                f"Date: {instance.date}"
            )
            
            # Update related entity information if needed
            if instance.labor:
                # Update labor's last payment date
                instance.labor.last_payment_date = timezone.now()
                instance.labor.save(update_fields=['last_payment_date'])
                
            elif instance.vendor:
                # Update vendor's last payment date
                instance.vendor.last_payment_date = timezone.now()
                instance.vendor.save(update_fields=['last_payment_date'])
                
        else:
            # Log payment update
            logger.info(
                f"Payment updated: {instance.id} - "
                f"Amount: {instance.amount_paid}, "
                f"Status: {'Active' if instance.is_active else 'Inactive'}"
            )
            
    except Exception as e:
        logger.error(f"Error in payment post-save signal: {str(e)}")


@receiver(post_delete, sender=Payment)
def payment_post_delete(sender, instance, **kwargs):
    """
    Signal handler for payment post-delete operations
    """
    try:
        # Log payment deletion
        logger.info(
            f"Payment deleted: {instance.id} - "
            f"Amount: {instance.amount_paid}, "
            f"Payer: {instance.payer_type}, "
            f"Date: {instance.date}"
        )
        
    except Exception as e:
        logger.error(f"Error in payment post-delete signal: {str(e)}")


@receiver(post_save, sender=Payment)
def update_payment_statistics(sender, instance, **kwargs):
    """
    Signal handler to update payment statistics when payments change
    """
    try:
        # This could trigger cache invalidation or update summary tables
        # For now, just log the event
        if instance.is_final_payment:
            logger.info(
                f"Final payment marked: {instance.id} - "
                f"Amount: {instance.amount_paid}, "
                f"Month: {instance.payment_month}"
            )
            
    except Exception as e:
        logger.error(f"Error updating payment statistics: {str(e)}")
