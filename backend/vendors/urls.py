from django.urls import path
from . import views

app_name = 'vendors'

urlpatterns = [
    # Core CRUD operations
    path('', views.list_vendors, name='list_vendors'),
    path('create/', views.create_vendor, name='create_vendor'),
    path('<uuid:vendor_id>/', views.get_vendor, name='get_vendor'),
    path('<uuid:vendor_id>/update/', views.update_vendor, name='update_vendor'),
    
    # Hard delete (permanent deletion)
    path('<uuid:vendor_id>/delete/', views.delete_vendor, name='delete_vendor'),
    
    # Soft delete operations
    path('<uuid:vendor_id>/soft-delete/', views.soft_delete_vendor, name='soft_delete_vendor'),
    path('<uuid:vendor_id>/restore/', views.restore_vendor, name='restore_vendor'),
    
    # Search and filtering
    path('search/', views.search_vendors, name='search_vendors'),
    path('city/<str:city_name>/', views.vendors_by_city, name='vendors_by_city'),
    path('area/<str:area_name>/', views.vendors_by_area, name='vendors_by_area'),
    
    # Recent vendors
    path('recent/', views.recent_vendors, name='recent_vendors'),
    
    # Statistics and analytics
    path('statistics/', views.vendor_statistics, name='vendor_statistics'),
    
    # Integration endpoints
    path('<uuid:vendor_id>/payments/', views.vendor_payments, name='vendor_payments'),
    path('<uuid:vendor_id>/transactions/', views.vendor_transactions, name='vendor_transactions'),
    
    # Bulk operations
    path('bulk-actions/', views.bulk_vendor_actions, name='bulk_vendor_actions'),
    
    # Import/Export
    path('import/', views.import_vendors, name='import_vendors'),
    path('export/', views.export_vendors, name='export_vendors'),
    
    # Helper endpoints
    path('cities/', views.vendor_cities_list, name='vendor_cities_list'),
    path('areas/', views.vendor_areas_list, name='vendor_areas_list'),
    path('<uuid:vendor_id>/add-note/', views.add_vendor_note, name='add_vendor_note'),
]