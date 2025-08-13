from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/v1/', include('posapi.urls')),
    path('api/v1/categories/', include('categories.urls')),
    path('api/v1/products/', include('products.urls')),
    path('api/v1/customers/', include('customers.urls')),
    path('api/v1/vendors/', include('vendors.urls')),
    path('api/v1/labors/', include('labors.urls')),
]