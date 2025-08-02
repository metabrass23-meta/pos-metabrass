from django.urls import path
from . import views

app_name = 'products'

urlpatterns = [
    # Core CRUD operations
    path('', views.list_products, name='list_products'),
    path('create/', views.create_product, name='create_product'),
    path('<uuid:product_id>/', views.get_product, name='get_product'),
    path('<uuid:product_id>/update/', views.update_product, name='update_product'),
    
    # Hard delete (permanent deletion)
    path('<uuid:product_id>/delete/', views.delete_product, name='delete_product'),
    
    # Soft delete operations
    path('<uuid:product_id>/soft-delete/', views.soft_delete_product, name='soft_delete_product'),
    path('<uuid:product_id>/restore/', views.restore_product, name='restore_product'),
    
    # Search and filtering
    path('search/', views.search_products, name='search_products'),
    path('category/<uuid:category_id>/', views.products_by_category, name='products_by_category'),
    path('low-stock/', views.low_stock_products, name='low_stock_products'),
    
    # Statistics and analytics
    path('statistics/', views.product_statistics, name='product_statistics'),
    
    # Quantity management
    path('<uuid:product_id>/quantity/', views.update_product_quantity, name='update_product_quantity'),
    path('bulk-update-quantities/', views.bulk_update_quantities, name='bulk_update_quantities'),
    
    # Product operations
    path('<uuid:product_id>/duplicate/', views.duplicate_product, name='duplicate_product'),
]
