from django.urls import path, include
from rest_framework.routers import DefaultRouter
from . import views

router = DefaultRouter()
router.register(r'roles', views.RoleViewSet, basename='role')
router.register(r'users', views.UserManagementViewSet, basename='user-management')

# URL patterns for the posapi app
urlpatterns = [
    path('', include(router.urls)),
    
    # Authentication endpoints
    path('auth/register/', views.register_user, name='register'),
    path('auth/login/', views.login_user, name='login'),
    path('auth/logout/', views.logout_user, name='logout'),
    
    # User profile endpoints
    path('auth/profile/', views.get_user_profile, name='user-profile'),
    path('auth/profile/update/', views.update_user_profile, name='update-profile'),
    path('auth/change-password/', views.change_password, name='change-password'),
    
    # Custom Role endpoints
    path('roles/<int:role_id>/permissions/', views.update_role_permissions, name='update-role-permissions'),
]
