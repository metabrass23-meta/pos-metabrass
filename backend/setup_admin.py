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
    
    # Set all permissions to True for Admin
    modules = [
        'Dashboard', 'Sale', 'Purchase', 'Product', 'Customer', 'Vendor',
        'Order', 'Expense', 'Labor', 'Payment', 'Receipt', 'Return',
        'Quotation', 'Inventory', 'Payable', 'Receivable', 'Profit Loss',
        'Category', 'Zakat', 'User Management'
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
    
    # Assign Admin role to all existing users for now (or just the first one)
    # The user asked if their first user will be admin.
    first_user = User.objects.first()
    if first_user:
        first_user.role = admin_role
        first_user.save()
        print(f"Successfully assigned Admin role to: {first_user.email}")
    else:
        print("No users found in the database.")

if __name__ == '__main__':
    setup_admin()
