from rest_framework import generics
from .models import Purchase
from .serializers import PurchaseSerializer


class PurchaseListCreateView(generics.ListCreateAPIView):
    queryset = Purchase.objects.all().order_by('-created_at')
    serializer_class = PurchaseSerializer


class PurchaseDetailView(generics.RetrieveAPIView):
    queryset = Purchase.objects.all()
    serializer_class = PurchaseSerializer
