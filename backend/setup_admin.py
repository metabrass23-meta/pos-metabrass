import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'core.settings')
django.setup()

from posapi.models import User, Role, ModulePermission

def setup_admin():
    # Create Admin Role
    admin_role, created = Role.objects.get_or_create(
        name='Admin', 
        defaults={'description': 'Full System Access'}
    )
    
    # Set all permissions to True for Admin (Full Standardized List)
    modules = [
        'Dashboard', 'Sales', 'Purchases', 'Products', 'Category', 
        'Quotations', 'Customers', 'Vendor', 'Labour', 'Receivables', 
        'Payables', 'Advance Payment', 'Payments', 'Expenses', 
        'Principal Account', 'Zakat', 'Profit & Loss', 'Returns', 
        'Invoices', 'Receipts', 'User Management', 'Roles & Permissions', 
        'Settings', 'Tax Management'
    ]
    
    for module in modules:
        ModulePermission.objects.update_or_create(
            role=admin_role,
            module_name=module,
            defaults={
                'can_view': True,
                'can_add': True,
                'can_edit': True,
                'can_delete': True
            }
        )
    
    # Target specific user as requested: irfan@gmail.com
    target_email = 'irfan@gmail.com'
    try:
        user = User.objects.get(email=target_email)
        user.role = admin_role
        user.is_superuser = True
        user.is_staff = True
        user.save()
        print(f"Successfully assigned Admin role and Superuser status to: {user.email}")
    except User.DoesNotExist:
        # Fallback to first user if irfan@gmail.com doesn't exist
        first_user = User.objects.first()
        if first_user:
            first_user.role = admin_role
            first_user.is_superuser = True
            first_user.is_staff = True
            first_user.save()
            print(f"Fallback: Assigned Admin role to: {first_user.email}")
        else:
            print("No users found in the database. Please register an account first.")

if __name__ == '__main__':
    setup_admin()
