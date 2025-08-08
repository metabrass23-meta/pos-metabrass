from django.db.models.signals import post_save, pre_save, post_delete
from django.dispatch import receiver
from django.core.mail import send_mail
from django.conf import settings
from django.utils import timezone
from django.contrib.auth.models import User
from .models import Vendor, VendorNote
import logging

logger = logging.getLogger(__name__)


@receiver(pre_save, sender=Vendor)
def vendor_pre_save(sender, instance, **kwargs):
    """Signal handler for before vendor save"""
    # Clean and format phone number
    if instance.phone:
        instance.phone = instance.format_phone_number(instance.phone)
    
    # Normalize city and area names
    if instance.city:
        instance.city = instance.city.title().strip()
    
    if instance.area:
        instance.area = instance.area.title().strip()
    
    # Log vendor creation/update
    if instance.pk:
        logger.info(f"Vendor {instance.name} is being updated")
    else:
        logger.info(f"New vendor {instance.name} is being created")


@receiver(post_save, sender=Vendor)
def vendor_post_save(sender, instance, created, **kwargs):
    """Signal handler for after vendor save"""
    if created:
        # Log successful creation
        logger.info(f"Vendor {instance.name} (ID: {instance.id}) has been created successfully")
        
        # Send notification email to admin (if configured)
        if hasattr(settings, 'VENDOR_NOTIFICATION_EMAIL') and settings.VENDOR_NOTIFICATION_EMAIL:
            try:
                send_notification_email_new_vendor(instance)
            except Exception as e:
                logger.error(f"Failed to send notification email for new vendor {instance.name}: {str(e)}")
        
        # Create welcome note (optional)
        if hasattr(settings, 'AUTO_CREATE_WELCOME_NOTE') and settings.AUTO_CREATE_WELCOME_NOTE:
            try:
                VendorNote.objects.create(
                    vendor=instance,
                    note=f"Welcome to our vendor network! Vendor {instance.name} was added on {timezone.now().strftime('%Y-%m-%d')}.",
                    created_by=instance.created_by
                )
            except Exception as e:
                logger.error(f"Failed to create welcome note for vendor {instance.name}: {str(e)}")
    
    else:
        # Log update
        logger.info(f"Vendor {instance.name} has been updated")
        
        # Check if vendor was reactivated
        if instance.is_active:
            original = Vendor.objects.get(pk=instance.pk)
            # Note: This is a simplified check - in production you might want to track field changes
            logger.info(f"Vendor {instance.name} status checked - currently active")


@receiver(post_save, sender=VendorNote)
def vendor_note_post_save(sender, instance, created, **kwargs):
    """Signal handler for after vendor note save"""
    if created:
        logger.info(f"New note added for vendor {instance.vendor.name} by {instance.created_by}")


# Utility functions for signal handlers

def send_notification_email_new_vendor(vendor):
    """Send notification email when a new vendor is created"""
    subject = f'New Vendor Added: {vendor.name}'
    message = f"""
    A new vendor has been added to the system:
    
    Name: {vendor.name}
    Business: {vendor.business_name}
    CNIC: {vendor.cnic}
    Phone: {vendor.phone}
    Location: {vendor.full_address}
    Created by: {vendor.created_by.get_full_name() if vendor.created_by else 'System'}
    Created at: {vendor.created_at.strftime('%Y-%m-%d %H:%M:%S')}
    
    You can view the vendor details in the admin panel.
    """
    
    recipient_list = [settings.VENDOR_NOTIFICATION_EMAIL]
    if isinstance(recipient_list, str):
        recipient_list = [recipient_list]
    
    send_mail(
        subject=subject,
        message=message,
        from_email=settings.DEFAULT_FROM_EMAIL,
        recipient_list=recipient_list,
        fail_silently=True
    )


def send_vendor_reactivation_email(vendor):
    """Send notification when a vendor is reactivated"""
    subject = f'Vendor Reactivated: {vendor.name}'
    message = f"""
    The following vendor has been reactivated:
    
    Name: {vendor.name}
    Business: {vendor.business_name}
    Phone: {vendor.phone}
    Location: {vendor.full_address}
    Reactivated at: {timezone.now().strftime('%Y-%m-%d %H:%M:%S')}
    """
    
    if hasattr(settings, 'VENDOR_NOTIFICATION_EMAIL') and settings.VENDOR_NOTIFICATION_EMAIL:
        recipient_list = [settings.VENDOR_NOTIFICATION_EMAIL]
        if isinstance(recipient_list, str):
            recipient_list = [recipient_list]
        
        send_mail(
            subject=subject,
            message=message,
            from_email=settings.DEFAULT_FROM_EMAIL,
            recipient_list=recipient_list,
            fail_silently=True
        )


# Custom signal for vendor status changes
from django.dispatch import Signal

vendor_status_changed = Signal()
vendor_bulk_action_completed = Signal()


@receiver(vendor_status_changed)
def handle_vendor_status_change(sender, vendor, old_status, new_status, **kwargs):
    """Handle vendor status changes"""
    logger.info(f"Vendor {vendor.name} status changed from {old_status} to {new_status}")
    
    if old_status == False and new_status == True:
        # Vendor was reactivated
        send_vendor_reactivation_email(vendor)
    elif old_status == True and new_status == False:
        # Vendor was deactivated
        logger.warning(f"Vendor {vendor.name} has been deactivated")


@receiver(vendor_bulk_action_completed)
def handle_bulk_action_completed(sender, action, count, **kwargs):
    """Handle completion of bulk actions"""
    logger.info(f"Bulk action '{action}' completed on {count} vendors")
    
    # Send notification for bulk actions if configured
    if hasattr(settings, 'NOTIFY_BULK_ACTIONS') and settings.NOTIFY_BULK_ACTIONS:
        if hasattr(settings, 'VENDOR_NOTIFICATION_EMAIL') and settings.VENDOR_NOTIFICATION_EMAIL:
            subject = f'Bulk Action Completed: {action}'
            message = f'Bulk action "{action}" has been completed on {count} vendors.'
            
            send_mail(
                subject=subject,
                message=message,
                from_email=settings.DEFAULT_FROM_EMAIL,
                recipient_list=[settings.VENDOR_NOTIFICATION_EMAIL],
                fail_silently=True
            )


# Database cleanup signals
@receiver(post_delete, sender=Vendor)
def vendor_post_delete(sender, instance, **kwargs):
    """Signal handler for after vendor deletion"""
    logger.warning(f"Vendor {instance.name} (ID: {instance.id}) has been permanently deleted")


# Performance monitoring signals
@receiver(post_save, sender=Vendor)
def monitor_vendor_creation_rate(sender, instance, created, **kwargs):
    """Monitor vendor creation rate for analytics"""
    if created:
        # This could be used to track vendor creation metrics
        # You might want to implement rate limiting or alerts here
        
        from datetime import timedelta
        today = timezone.now().date()
        recent_count = Vendor.objects.filter(
            created_at__date=today
        ).count()
        
        # Alert if too many vendors created in one day (configurable threshold)
        threshold = getattr(settings, 'DAILY_VENDOR_CREATION_THRESHOLD', 100)
        if recent_count >= threshold:
            logger.warning(
                f"High vendor creation rate detected: {recent_count} vendors created today"
            )


# Data validation signals
@receiver(pre_save, sender=Vendor)
def validate_vendor_data_integrity(sender, instance, **kwargs):
    """Additional data integrity validation"""
    # Check for potential duplicate business names in same city
    if instance.business_name and instance.city:
        similar_vendors = Vendor.objects.filter(
            business_name__iexact=instance.business_name,
            city__iexact=instance.city,
            is_active=True
        ).exclude(pk=instance.pk)
        
        if similar_vendors.exists():
            logger.warning(
                f"Potential duplicate business detected: {instance.business_name} in {instance.city}"
            )
    
    # Validate phone number uniqueness (soft warning)
    if instance.phone:
        duplicate_phones = Vendor.objects.filter(
            phone=instance.phone,
            is_active=True
        ).exclude(pk=instance.pk)
        
        if duplicate_phones.exists():
            logger.warning(
                f"Duplicate phone number detected for vendor {instance.name}: {instance.phone}"
            )
            