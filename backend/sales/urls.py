from django.urls import path
from . import views

app_name = 'sales'

urlpatterns = [
    # Sales endpoints
    path('', views.list_sales, name='list_sales'),
    path('create/', views.create_sale, name='create_sale'),
    path('<uuid:sale_id>/', views.get_sale, name='get_sale'),
    path('<uuid:sale_id>/update/', views.update_sale, name='update_sale'),
    path('<uuid:sale_id>/delete/', views.delete_sale, name='delete_sale'),
    path('<uuid:sale_id>/add-payment/', views.add_payment, name='add_payment'),
    path('<uuid:sale_id>/update-status/', views.update_status, name='update_status'),
    
    # Customer sales history
    path('by-customer/<uuid:customer_id>/', views.customer_sales_history, name='customer_sales_history'),
    
    # Sales analytics
    path('statistics/', views.sales_statistics, name='sales_statistics'),
    
    # Order conversion
    path('create-from-order/', views.create_from_order, name='create_from_order'),
    
    # Sale items endpoints
    path('items/', views.list_sale_items, name='list_sale_items'),
    path('items/create/', views.create_sale_item, name='create_sale_item'),
    path('items/<uuid:item_id>/update/', views.update_sale_item, name='update_sale_item'),
    path('items/<uuid:item_id>/delete/', views.delete_sale_item, name='delete_sale_item'),
]
