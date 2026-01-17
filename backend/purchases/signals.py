from django.db.models.signals import post_save
from django.dispatch import receiver

from purchases.models import Purchase, PurchaseItem
from payables.models import Payable


# ===============================
# STOCK UPDATE ON PURCHASE ITEM
# ===============================
@receiver(post_save, sender=PurchaseItem)
def increase_stock_on_purchase_item(sender, instance, created, **kwargs):
    """
    Increase product stock when a purchase item is created.
    """
    if not created:
        return

    product = instance.product
    product.stock += instance.quantity
    product.save()


# ====================================
# PAYABLE CREATION ON PURCHASE POSTED
# ====================================
@receiver(post_save, sender=Purchase)
def create_or_update_payable_on_purchase(sender, instance, created, **kwargs):
    """
    Create or update payable when a purchase is POSTED.
    Draft purchases are ignored.
    """

    # Ignore drafts
    if instance.status != "posted":
        return

    payable, payable_created = Payable.objects.get_or_create(
        purchase=instance,
        defaults={
            "amount": instance.total,
            "paid_amount": 0,
        }
    )

    # Sync amount if purchase total changes
    if not payable_created and payable.amount != instance.total:
        payable.amount = instance.total
        payable.save()
