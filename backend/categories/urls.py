from django.urls import path
from . import views

app_name = 'categories'

urlpatterns = [
    path('', views.list_categories, name='list_categories'),
    path('create/', views.create_category, name='create_category'),
    path('<uuid:category_id>/', views.get_category, name='get_category'),
    path('<uuid:category_id>/update/', views.update_category, name='update_category'),
    path('<uuid:category_id>/delete/', views.delete_category, name='delete_category'),
    path('<uuid:category_id>/restore/', views.restore_category, name='restore_category'),
]
