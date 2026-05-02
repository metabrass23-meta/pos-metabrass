import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'core.settings')
django.setup()

from posapi.models import User

def list_users():
    print(f"{'Email':<30} | {'Role':<15} | {'Is Superuser'}")
    print("-" * 60)
    for user in User.objects.all().select_related('role'):
        role_name = user.role.name if user.role else "None"
        print(f"{user.email:<30} | {role_name:<15} | {user.is_superuser}")

if __name__ == '__main__':
    list_users()
