from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/v1/', include('posapi.urls')),
    path('api/v1/categories/', include('categories.urls')),
    path('api/v1/products/', include('products.urls')),
    path('api/v1/customers/', include('customers.urls')),
    path('api/v1/vendors/', include('vendors.urls')),
    path('api/v1/labors/', include('labors.urls')),
    path('api/v1/advance-payments/', include('advance_payments.urls')),
    path('api/v1/orders/', include('orders.urls')),
    path('api/v1/order-items/', include('order_items.urls')),
    path('api/v1/payables/', include('payables.urls')),
]

# Serve media files during development
if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
    urlpatterns += static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)