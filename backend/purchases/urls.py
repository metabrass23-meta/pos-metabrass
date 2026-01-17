from django.urls import path
from .views import PurchaseListCreateView, PurchaseDetailView

app_name = 'purchases'

urlpatterns = [
    path('', PurchaseListCreateView.as_view(), name='list_create'),
    path('<uuid:pk>/', PurchaseDetailView.as_view(), name='detail'),
]
