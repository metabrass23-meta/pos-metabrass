from django.db.models.signals import post_save
from django.dispatch import receiver
from .models import PurchaseItem


@receiver(post_save, sender=PurchaseItem)
def increase_stock_on_purchase(sender, instance, created, **kwargs):
    if created:
        product = instance.product
        product.stock += instance.quantity
        product.save()
