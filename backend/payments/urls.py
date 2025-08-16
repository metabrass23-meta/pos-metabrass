from django.urls import path
from . import views

app_name = 'payments'

urlpatterns = [
    # Function-based view endpoints
    path('', views.list_payments, name='list_payments'),
    path('create/', views.create_payment, name='create_payment'),
    path('<uuid:payment_id>/', views.get_payment, name='get_payment'),
    path('<uuid:payment_id>/update/', views.update_payment, name='update_payment'),
    
    # Hard delete (permanent deletion)
    path('<uuid:payment_id>/delete/', views.delete_payment, name='delete_payment'),
    
    # Soft delete (alternative - sets is_active=False)
    path('<uuid:payment_id>/soft-delete/', views.soft_delete_payment, name='soft_delete_payment'),
    path('<uuid:payment_id>/restore/', views.restore_payment, name='restore_payment'),
    
    # Additional payment-specific endpoints
    path('statistics/', views.get_payment_statistics, name='get_payment_statistics'),
    path('<uuid:payment_id>/mark-final/', views.mark_as_final_payment, name='mark_as_final_payment'),
]
