from rest_framework import status, generics, permissions
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework.authtoken.models import Token
from rest_framework.permissions import IsAuthenticated, AllowAny
from django.contrib.auth import login, logout
from django.utils import timezone
from django.db import transaction
from .models import User, Role, ModulePermission
from .serializers import (
    UserRegistrationSerializer,
    UserLoginSerializer,
    UserSerializer,
    ChangePasswordSerializer,
    RoleSerializer,
    ModulePermissionSerializer
)
from rest_framework import viewsets
from rest_framework.routers import DefaultRouter



@api_view(['POST'])
@permission_classes([AllowAny])
def register_user(request):
    """
    Register a new user
    """
    serializer = UserRegistrationSerializer(data=request.data)
    
    if serializer.is_valid():
        try:
            with transaction.atomic():
                user = serializer.save()
                
                # Create authentication token
                token, created = Token.objects.get_or_create(user=user)
                
                return Response({
                    'success': True,
                    'message': 'User registered successfully.',
                    'data': {
                        'user': UserSerializer(user).data,
                        'token': token.key
                    }
                }, status=status.HTTP_201_CREATED)
                
        except Exception as e:
            return Response({
                'success': False,
                'message': 'Registration failed due to server error.',
                'errors': {'detail': str(e)}
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    
    print(f"DEBUG: Registration validation errors: {serializer.errors}")
    return Response({
        'success': False,
        'message': 'Registration failed.',
        'errors': serializer.errors
    }, status=status.HTTP_400_BAD_REQUEST)


@api_view(['POST'])
@permission_classes([AllowAny])
def login_user(request):
    """
    Login user with email and password
    """
    serializer = UserLoginSerializer(
        data=request.data,
        context={'request': request}
    )
    
    if serializer.is_valid():
        try:
            user = serializer.validated_data['user']
            
            # Update last login
            user.last_login = timezone.now()
            user.save(update_fields=['last_login'])
            
            # Get or create token
            token, created = Token.objects.get_or_create(user=user)
            
            # Login user (for session-based auth if needed)
            login(request, user)
            
            return Response({
                'success': True,
                'message': 'Login successful.',
                'data': {
                    'user': UserSerializer(user).data,
                    'token': token.key
                }
            }, status=status.HTTP_200_OK)
            
        except Exception as e:
            return Response({
                'success': False,
                'message': 'Login failed due to server error.',
                'errors': {'detail': str(e)}
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    
    return Response({
        'success': False,
        'message': 'Login failed.',
        'errors': serializer.errors
    }, status=status.HTTP_400_BAD_REQUEST)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def logout_user(request):
    """
    Logout user and delete token
    """
    try:
        # Delete the user's token
        token = Token.objects.get(user=request.user)
        token.delete()
        
        # Logout user from session
        logout(request)
        
        return Response({
            'success': True,
            'message': 'Logout successful.'
        }, status=status.HTTP_200_OK)
        
    except Token.DoesNotExist:
        # Token doesn't exist, but still logout the session
        logout(request)
        return Response({
            'success': True,
            'message': 'Logout successful.'
        }, status=status.HTTP_200_OK)
        
    except Exception as e:
        return Response({
            'success': False,
            'message': 'Logout failed.',
            'error': str(e)
        }, status=status.HTTP_400_BAD_REQUEST)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_user_profile(request):
    """
    Get current user profile
    """
    serializer = UserSerializer(request.user)
    
    return Response({
        'success': True,
        'data': serializer.data
    }, status=status.HTTP_200_OK)


@api_view(['PUT', 'PATCH'])
@permission_classes([IsAuthenticated])
def update_user_profile(request):
    """
    Update user profile
    """
    serializer = UserSerializer(
        request.user,
        data=request.data,
        partial=request.method == 'PATCH'
    )
    
    if serializer.is_valid():
        serializer.save()
        
        return Response({
            'success': True,
            'message': 'Profile updated successfully.',
            'data': serializer.data
        }, status=status.HTTP_200_OK)
    
    return Response({
        'success': False,
        'message': 'Profile update failed.',
        'errors': serializer.errors
    }, status=status.HTTP_400_BAD_REQUEST)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def change_password(request):
    """
    Change user password
    """
    serializer = ChangePasswordSerializer(
        data=request.data,
        context={'request': request}
    )
    
    if serializer.is_valid():
        try:
            user = request.user
            user.set_password(serializer.validated_data['new_password'])
            user.save()
            
            # Delete old token and create new one for security
            try:
                old_token = Token.objects.get(user=user)
                old_token.delete()
            except Token.DoesNotExist:
                pass
            
            token = Token.objects.create(user=user)
            
            return Response({
                'success': True,
                'message': 'Password changed successfully.',
                'data': {
                    'token': token.key
                }
            }, status=status.HTTP_200_OK)
            
        except Exception as e:
            return Response({
                'success': False,
                'message': 'Password change failed due to server error.',
                'errors': {'detail': str(e)}
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    
    return Response({
        'success': False,
        'message': 'Password change failed.',
        'errors': serializer.errors
    }, status=status.HTTP_400_BAD_REQUEST)


# Class-based views alternative (more DRF standard)
class UserRegistrationAPIView(generics.CreateAPIView):
    """Class-based view for user registration"""
    queryset = User.objects.all()
    serializer_class = UserRegistrationSerializer
    permission_classes = [AllowAny]
    
    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.save()
        
        token, created = Token.objects.get_or_create(user=user)
        
        return Response({
            'success': True,
            'message': 'User registered successfully.',
            'data': {
                'user': UserSerializer(user).data,
                'token': token.key
            }
        }, status=status.HTTP_201_CREATED)


class UserProfileAPIView(generics.RetrieveUpdateAPIView):
    """Class-based view for user profile"""
    serializer_class = UserSerializer
    permission_classes = [IsAuthenticated]
    
    def get_object(self):
        return self.request.user

class RoleViewSet(viewsets.ModelViewSet):
    """ViewSet for managing roles and permissions"""
    queryset = Role.objects.all()
    serializer_class = RoleSerializer
    permission_classes = [IsAuthenticated]
    pagination_class = None

    def list(self, request, *args, **kwargs):
        response = super().list(request, *args, **kwargs)
        return Response({
            'success': True,
            'data': response.data
        })

    def retrieve(self, request, *args, **kwargs):
        response = super().retrieve(request, *args, **kwargs)
        return Response({
            'success': True,
            'data': response.data
        })

    @transaction.atomic
    def perform_create(self, serializer):
        role = serializer.save()
        # Initialize default permissions for all modules (Matching Sidebar Labels)
        modules = [
            'Dashboard', 'Sales', 'Purchases', 'Products', 'Category', 
            'Quotations', 'Customers', 'Vendor', 'Labour', 'Receivables', 
            'Payables', 'Advance Payment', 'Payments', 'Expenses', 
            'Principal Account', 'Zakat', 'Profit & Loss', 'Returns', 
            'Invoices', 'Receipts', 'User Management', 'Roles & Permissions', 
            'Settings', 'Tax Management'
        ]
        for module in modules:
            ModulePermission.objects.get_or_create(
                role=role,
                module_name=module,
                defaults={'can_view': False, 'can_add': False, 'can_edit': False, 'can_delete': False}
            )

    def create(self, request, *args, **kwargs):
        response = super().create(request, *args, **kwargs)
        return Response({
            'success': True,
            'message': 'Role created successfully.',
            'data': response.data
        }, status=status.HTTP_201_CREATED)

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def update_role_permissions(request, role_id):
    """Update permissions for a specific role"""
    try:
        role = Role.objects.get(pk=role_id)
        permissions_data = request.data.get('permissions', [])
        
        for perm_data in permissions_data:
            module_name = perm_data.get('module_name')
            ModulePermission.objects.update_or_create(
                role=role,
                module_name=module_name,
                defaults={
                    'can_view': perm_data.get('can_view', False),
                    'can_add': perm_data.get('can_add', False),
                    'can_edit': perm_data.get('can_edit', False),
                    'can_delete': perm_data.get('can_delete', False),
                }
            )
        
        return Response({'success': True, 'message': 'Permissions updated successfully.'})
    except Role.DoesNotExist:
        return Response({'success': False, 'message': 'Role not found.'}, status=status.HTTP_404_NOT_FOUND)
    except Exception as e:
        return Response({'success': False, 'message': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

class UserManagementViewSet(viewsets.ModelViewSet):
    """ViewSet for admin to manage users"""
    queryset = User.objects.all()
    serializer_class = UserSerializer
    permission_classes = [IsAuthenticated] # Should ideally be IsAdminUser
    pagination_class = None

    def list(self, request, *args, **kwargs):
        response = super().list(request, *args, **kwargs)
        return Response({
            'success': True,
            'data': response.data
        })

    def retrieve(self, request, *args, **kwargs):
        response = super().retrieve(request, *args, **kwargs)
        return Response({
            'success': True,
            'data': response.data
        })

    def perform_create(self, serializer):
        # Override create to handle password setting if provided
        password = self.request.data.get('password')
        user = serializer.save()
        if password:
            user.set_password(password)
            user.save()

    def create(self, request, *args, **kwargs):
        response = super().create(request, *args, **kwargs)
        return Response({
            'success': True,
            'message': 'User created successfully.',
            'data': response.data
        }, status=status.HTTP_201_CREATED)

    def perform_update(self, serializer):
        password = self.request.data.get('password')
        user = serializer.save()
        if password:
            user.set_password(password)
            user.save()

    def update(self, request, *args, **kwargs):
        response = super().update(request, *args, **kwargs)
        return Response({
            'success': True,
            'message': 'User updated successfully.',
            'data': response.data
        }, status=status.HTTP_200_OK)

    def destroy(self, request, *args, **kwargs):
        super().destroy(request, *args, **kwargs)
        return Response({
            'success': True,
            'message': 'User deleted successfully.'
        }, status=status.HTTP_200_OK)

    