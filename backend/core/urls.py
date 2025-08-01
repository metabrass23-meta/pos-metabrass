from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/v1/', include('posapi.urls')),
    # You can also add API documentation URLs here later
    # path('api/docs/', include('rest_framework.urls')),
]