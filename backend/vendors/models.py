import uuid
import re
from django.db import models
from django.contrib.auth import get_user_model
from django.core.validators import RegexValidator
from django.core.exceptions import ValidationError
from django.utils import timezone

# Get the custom user model
User = get_user_model()


class VendorManager(models.Manager):
    """Custom manager for Vendor model with additional query methods"""
    
    def active(self):
        """Return only active vendors"""
        return self.filter(is_active=True)
    
    def inactive(self):
        """Return only inactive vendors"""
        return self.filter(is_active=False)
    
    def by_city(self, city):
        """Filter vendors by city"""
        return self.active().filter(city__icontains=city)
    
    def by_area(self, area):
        """Filter vendors by area"""
        return self.active().filter(area__icontains=area)
    
    def search(self, query):
        """Search vendors by name, business name, phone, or CNIC"""
        return self.active().filter(
            models.Q(name__icontains=query) |
            models.Q(business_name__icontains=query) |
            models.Q(phone__icontains=query) |
            models.Q(cnic__icontains=query)
        )
    
    def recent(self, days=30):
        """Get vendors created in the last N days"""
        from datetime import timedelta
        date_threshold = timezone.now() - timedelta(days=days)
        return self.active().filter(created_at__gte=date_threshold)


def validate_pakistani_cnic(value):
    """Validate Pakistani CNIC format: 42101-1234567-8"""
    pattern = r'^\d{5}-\d{7}-\d{1}$'
    if not re.match(pattern, value):
        raise ValidationError(
            'CNIC must be in format: 12345-1234567-1'
        )


def validate_pakistani_phone(value):
    """Validate Pakistani phone number format"""
    # Remove spaces and dashes for validation
    cleaned = re.sub(r'[-\s]', '', value)
    
    # Pakistani phone patterns
    patterns = [
        r'^(\+92|92|0)?3\d{9}$',  # Mobile: +923001234567, 923001234567, 03001234567
        r'^(\+92|92|0)?[2-9]\d{7,10}$',  # Landline variations
    ]
    
    if not any(re.match(pattern, cleaned) for pattern in patterns):
        raise ValidationError(
            'Please enter a valid Pakistani phone number'
        )


class Vendor(models.Model):
    """Vendor model for managing business vendors"""
    
    # Phone validator
    phone_regex = RegexValidator(
        regex=r'^[\+]?[0-9\-\s]{10,15}$',
        message="Phone number must be entered in valid format"
    )
    
    # Primary fields
    id = models.UUIDField(
        primary_key=True, 
        default=uuid.uuid4, 
        editable=False
    )
    name = models.CharField(
        max_length=100,
        help_text="Full name of the vendor"
    )
    business_name = models.CharField(
        max_length=150,
        help_text="Name of the business/company"
    )
    cnic = models.CharField(
        max_length=15,
        unique=True,
        validators=[validate_pakistani_cnic],
        help_text="Pakistani CNIC in format: 12345-1234567-1"
    )
    phone = models.CharField(
        max_length=20,
        validators=[phone_regex, validate_pakistani_phone],
        help_text="Contact phone number"
    )
    
    # Location fields
    city = models.CharField(
        max_length=50,
        help_text="City where vendor is located"
    )
    area = models.CharField(
        max_length=100,
        help_text="Area/locality within the city"
    )
    
    # Status and metadata
    is_active = models.BooleanField(
        default=True,
        help_text="Whether the vendor is active (for soft deletion)"
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    created_by = models.ForeignKey(
        User,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='created_vendors'
    )
    
    # Custom manager
    objects = VendorManager()
    
    class Meta:
        ordering = ['-created_at', 'name']
        verbose_name = 'Vendor'
        verbose_name_plural = 'Vendors'
        indexes = [
            models.Index(fields=['name']),
            models.Index(fields=['business_name']),
            models.Index(fields=['city']),
            models.Index(fields=['area']),
            models.Index(fields=['cnic']),
            models.Index(fields=['phone']),
            models.Index(fields=['is_active']),
            models.Index(fields=['created_at']),
        ]
    
    def __str__(self):
        return f"{self.name} ({self.business_name})"
    
    def clean(self):
        """Additional model validation"""
        super().clean()
        
        # Ensure CNIC is unique among active vendors
        if self.is_active:
            existing = Vendor.objects.filter(
                cnic=self.cnic, 
                is_active=True
            ).exclude(pk=self.pk)
            
            if existing.exists():
                raise ValidationError({
                    'cnic': 'An active vendor with this CNIC already exists.'
                })
        
        # Clean and format phone number
        if self.phone:
            self.phone = self.format_phone_number(self.phone)
    
    @staticmethod
    def format_phone_number(phone):
        """Format phone number to a consistent format"""
        # Remove all non-digit characters except +
        cleaned = re.sub(r'[^\d+]', '', phone)
        
        # Handle Pakistani mobile numbers
        if cleaned.startswith('03') and len(cleaned) == 11:
            return f"+92-{cleaned[1:]}"
        elif cleaned.startswith('923') and len(cleaned) == 12:
            return f"+{cleaned[:2]}-{cleaned[2:]}"
        elif cleaned.startswith('+923') and len(cleaned) == 13:
            return f"{cleaned[:3]}-{cleaned[3:]}"
        
        return phone  # Return original if no pattern matches
    
    def soft_delete(self):
        """Soft delete the vendor"""
        self.is_active = False
        self.save(update_fields=['is_active', 'updated_at'])
    
    def restore(self):
        """Restore soft deleted vendor"""
        self.is_active = True
        self.save(update_fields=['is_active', 'updated_at'])
    
    @property
    def full_address(self):
        """Return complete address"""
        return f"{self.area}, {self.city}"
    
    @property
    def display_phone(self):
        """Return formatted phone number for display"""
        return self.phone
    
    @property
    def initials(self):
        """Get initials for avatar display"""
        names = self.name.split()
        if len(names) >= 2:
            return f"{names[0][0]}{names[-1][0]}".upper()
        return self.name[:2].upper() if self.name else "V"
    
    # Payment-related methods (to be implemented with Payment model)
    def get_payments_count(self):
        """Get total number of payments made to this vendor"""
        # This will be implemented when Payment model is available
        return 0
    
    def get_total_payments_amount(self):
        """Get total amount paid to this vendor"""
        # This will be implemented when Payment model is available
        return 0.00
    
    def get_last_payment_date(self):
        """Get date of last payment to this vendor"""
        # This will be implemented when Payment model is available
        return None
    
    def get_average_payment_amount(self):
        """Get average payment amount for this vendor"""
        # This will be implemented when Payment model is available
        return 0.00


class VendorNote(models.Model):
    """Additional notes for vendors"""
    
    vendor = models.ForeignKey(
        Vendor,
        on_delete=models.CASCADE,
        related_name='notes'
    )
    note = models.TextField()
    created_by = models.ForeignKey(
        User,
        on_delete=models.SET_NULL,
        null=True,
        blank=True
    )
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        ordering = ['-created_at']
    
    def __str__(self):
        return f"Note for {self.vendor.name} - {self.created_at.strftime('%Y-%m-%d')}"
        