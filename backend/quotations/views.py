from rest_framework import viewsets, status, filters
from rest_framework.decorators import action, renderer_classes
from rest_framework.renderers import StaticHTMLRenderer, JSONRenderer
from rest_framework.response import Response
from rest_framework.permissions import AllowAny
from django_filters.rest_framework import DjangoFilterBackend
from .models import Quotation, QuotationItem
from .serializers import (
    QuotationSerializer, 
    QuotationCreateSerializer, 
    QuotationUpdateSerializer
)
import logging
import os
from django.conf import settings

logger = logging.getLogger(__name__)

class QuotationViewSet(viewsets.ModelViewSet):
    queryset = Quotation.objects.filter(is_active=True)
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['status', 'customer', 'conversion_status']
    search_fields = ['customer_name', 'customer_phone', 'description', 'items__product_name']
    ordering_fields = ['date_issued', 'grand_total', 'created_at']
    ordering = ['-created_at']
    
    def get_serializer_class(self):
        if self.action == 'create':
            return QuotationCreateSerializer
        elif self.action in ['update', 'partial_update']:
            return QuotationUpdateSerializer
        return QuotationSerializer

    def destroy(self, request, *args, **kwargs):
        instance = self.get_object()
        instance.is_active = False
        instance.save()
        return Response(status=status.HTTP_204_NO_CONTENT)

    @action(detail=True, methods=['get'], permission_classes=[AllowAny])
    @renderer_classes([StaticHTMLRenderer])
    def generate_pdf(self, request, pk=None):
        """Generate PDF for quotation matching the specific CASH RECEIPT design"""
        try:
            from reportlab.lib.pagesizes import A4
            from reportlab.platypus import SimpleDocTemplate, Table, TableStyle, Paragraph, Spacer, Image
            from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
            from reportlab.lib.units import inch
            from reportlab.lib import colors
            from io import BytesIO
            from django.http import HttpResponse
            from datetime import datetime

            quotation = self.get_object()
            q_id = quotation.quotation_number if quotation.quotation_number else str(quotation.id)[:8].upper()

            buffer = BytesIO()
            # Reduce margins to match the screenshot
            doc = SimpleDocTemplate(buffer, pagesize=A4, rightMargin=30, leftMargin=30, topMargin=30, bottomMargin=30)
            story = []

            styles = getSampleStyleSheet()
            
            # Custom Styles based on screenshot
            title_style = ParagraphStyle(
                'ReceiptTitle',
                fontSize=26,
                textColor=colors.HexColor("#305496"), # Dark Blue from screenshot
                fontName='Helvetica-Bold',
                alignment=2, # Right aligned
                spaceAfter=5
            )
            
            brand_style = ParagraphStyle(
                'BrandName',
                fontSize=14,
                fontName='Helvetica-Bold',
                alignment=2,
                spaceAfter=2
            )
            
            address_style = ParagraphStyle(
                'Address',
                fontSize=8,
                fontName='Helvetica',
                alignment=2,
                leading=10
            )

            # --- HEADER SECTION ---
            # Logo on left, Company info on right
            logo_path = os.path.join(settings.BASE_DIR, '..', 'frontend', 'assets', 'images', 'metabras.png')
            
            header_data = []
            logo_img = None
            if os.path.exists(logo_path):
                logo_img = Image(logo_path, width=1.5*inch, height=1.0*inch)
            
            # Right side text block
            right_text = [
                Paragraph("QUOTATION", title_style),
            ]
            
            header_table = Table([[logo_img, right_text]], colWidths=[3*inch, 4*inch])
            header_table.setStyle(TableStyle([
                ('VALIGN', (0, 0), (-1, -1), 'TOP'),
                ('ALIGN', (1, 0), (1, 0), 'RIGHT'),
            ]))
            story.append(header_table)
            story.append(Spacer(1, 15))

            # --- BLUE BANNER ---
            banner_style = ParagraphStyle(
                'Banner',
                fontSize=11,
                textColor=colors.white,
                fontName='Helvetica-Bold',
                alignment=0, # Left
                leftIndent=10
            )
            
            banner_data = [[Paragraph("SANITARY FITTINGS & BATHROOM ACCESSORIES", banner_style), Paragraph(">>> >>>", banner_style)]]
            banner_table = Table(banner_data, colWidths=[5.5*inch, 1.5*inch])
            banner_table.setStyle(TableStyle([
                ('BACKGROUND', (0, 0), (-1, -1), colors.HexColor("#2F5597")),
                ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
                ('TOPPADDING', (0, 0), (-1, -1), 8),
                ('BOTTOMPADDING', (0, 0), (-1, -1), 8),
            ]))
            story.append(banner_table)
            story.append(Spacer(1, 15))

            # --- INFO BOX (ROUNDED STYLE) ---
            # Receipt # and Date
            info_data = [
                [Paragraph(f"<b>Quotation #: QTN-{q_id}</b>", styles['Normal']), ""],
                [f"Date: {quotation.date_issued.strftime('%d %b %Y')}", ""]
            ]
            # Add a "PENDING" status badge logic in cell 1,0 if possible
            status_text = f"<b>{quotation.status}</b>"
            info_data[0][1] = Paragraph(status_text, ParagraphStyle('Status', alignment=1, fontSize=10, textColor=colors.HexColor("#2E7D32"), backColor=colors.HexColor("#C8E6C9"), borderPadding=5))

            info_table = Table(info_data, colWidths=[5*inch, 2*inch])
            info_table.setStyle(TableStyle([
                ('BOX', (0, 0), (-1, -1), 1, colors.lightgrey),
                ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
                ('LEFTPADDING', (0, 0), (-1, -1), 15),
                ('TOPPADDING', (0, 0), (-1, -1), 10),
                ('BOTTOMPADDING', (0, 0), (-1, -1), 10),
            ]))
            story.append(info_table)
            story.append(Spacer(1, 15))

            # --- CUSTOMER BAR ---
            cust_bar_data = [[f"CUSTOMER: {quotation.customer_name.upper() if quotation.customer_name else 'WALK-IN CUSTOMER'}"]]
            cust_bar_table = Table(cust_bar_data, colWidths=[7*inch])
            cust_bar_table.setStyle(TableStyle([
                ('BACKGROUND', (0, 0), (-1, -1), colors.HexColor("#F8F9FA")),
                ('FONTNAME', (0, 0), (-1, -1), 'Helvetica-Bold'),
                ('FONTSIZE', (0, 0), (-1, -1), 10),
                ('LEFTPADDING', (0, 0), (-1, -1), 15),
                ('TOPPADDING', (0, 0), (-1, -1), 8),
                ('BOTTOMPADDING', (0, 0), (-1, -1), 8),
            ]))
            story.append(cust_bar_table)
            story.append(Spacer(1, 15))

            # --- ITEMS TABLE ---
            items_data = [['ITEM', 'QTY', 'PRICE', 'TOTAL']]
            for item in quotation.items.all():
                items_data.append([
                    item.product_name,
                    str(float(item.quantity)),
                    str(int(item.unit_price)),
                    str(int(item.line_total)),
                ])

            # Adjust col widths to match screenshot
            items_table = Table(items_data, colWidths=[4*inch, 1*inch, 1*inch, 1*inch])
            items_table.setStyle(TableStyle([
                ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor("#E9ECEF")),
                ('TEXTCOLOR', (0, 0), (-1, 0), colors.black),
                ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
                ('FONTSIZE', (0, 0), (-1, -1), 10),
                ('GRID', (0, 0), (-1, -1), 0.5, colors.lightgrey),
                ('ALIGN', (1, 0), (-1, -1), 'CENTER'),
                ('ALIGN', (0, 0), (0, -1), 'LEFT'),
                ('BOTTOMPADDING', (0, 0), (-1, -1), 8),
                ('TOPPADDING', (0, 0), (-1, -1), 8),
            ]))
            story.append(items_table)

            # --- TOTALS SECTION ---
            summary_data = [
                ['Subtotal', f"PKR {int(quotation.base_amount)}"],
                # Divider line logic
                ['', ''],
                ['GRAND TOTAL', f"PKR {int(quotation.grand_total)}"],
                ['Status', quotation.status],
            ]
            
            summary_table = Table(summary_data, colWidths=[1.5*inch, 1.5*inch])
            summary_table.setStyle(TableStyle([
                ('ALIGN', (0, 0), (-1, -1), 'RIGHT'),
                ('FONTNAME', (0, 2), (0, 2), 'Helvetica-Bold'),
                ('FONTSIZE', (0, 2), (1, 2), 12),
                ('LINEABOVE', (1, 2), (1, 2), 1, colors.black),
                ('TOPPADDING', (0, 0), (-1, -1), 5),
            ]))
            
            # Use wrapper to push to right
            story.append(Table([[None, summary_table]], colWidths=[4*inch, 3*inch]))
            story.append(Spacer(1, 30))
            story.append(Table([["", ""]], colWidths=[0.5*inch, 6*inch], style=[('LINEBELOW', (1, 0), (1, 0), 1, colors.lightgrey)]))
            story.append(Spacer(1, 10))

            # --- FOOTER ---
            story.append(Paragraph("THANK YOU FOR YOUR BUSINESS!", ParagraphStyle('Footer1', alignment=1, fontName='Helvetica-Bold', fontSize=12)))
            story.append(Spacer(1, 10))
            
            footer_text = f"Software: MetaBrass POS System\nDate: {datetime.now().strftime('%d %b %Y, %I:%M %p')}"
            footer_para = Paragraph(footer_text, ParagraphStyle('Footer2', alignment=1, fontSize=8, leading=10))
            footer_table = Table([[footer_para]], colWidths=[7*inch])
            footer_table.setStyle(TableStyle([
                ('BACKGROUND', (0, 0), (-1, -1), colors.HexColor("#F8F9FA")),
                ('TOPPADDING', (0, 0), (-1, -1), 8),
                ('BOTTOMPADDING', (0, 0), (-1, -1), 8),
            ]))
            story.append(footer_table)

            doc.build(story)
            pdf_data = buffer.getvalue()
            buffer.close()

            response = HttpResponse(pdf_data, content_type='application/pdf')
            response['Content-Disposition'] = f'attachment; filename="quotation_{q_id}.pdf"'
            return response

        except Exception as e:
            logger.error(f"PDF Final Clone error: {str(e)}", exc_info=True)
            from django.http import JsonResponse
            return JsonResponse({"detail": str(e)}, status=400)

    @action(detail=True, methods=['post'])
    def convert_to_sale(self, request, pk=None):
        from sales.models import Sales, SaleItem
        from django.db import transaction
        from decimal import Decimal
        
        quotation = self.get_object()
        
        if quotation.conversion_status != 'NOT_CONVERTED':
            return Response(
                {"detail": "Quotation already converted."},
                status=status.HTTP_400_BAD_REQUEST
            )
            
        try:
            # Pre-check Stock Availability for all items
            insufficient_items = []
            for item in quotation.items.all():
                if item.product:
                    if item.product.quantity < item.quantity:
                        insufficient_items.append(f"{item.product.name} (Available: {item.product.quantity}, Required: {item.quantity})")
                else:
                    # If product is missing but item exists, we should probably warn
                    pass
            
            if insufficient_items:
                message = "Insufficient stock for: " + ", ".join(insufficient_items)
                return Response({"detail": message}, status=status.HTTP_400_BAD_REQUEST)

            with transaction.atomic():
                if quotation.status != 'ACCEPTED':
                    quotation.status = 'ACCEPTED'
                    
                quotation.conversion_status = 'CONVERTED_TO_SALE'
                quotation.save()
                
                subtotal = Decimal(str(quotation.base_amount))
                if subtotal <= 0:
                    subtotal = Decimal(str(quotation.grand_total)) + Decimal(str(quotation.discount_amount))
                    
                sale = Sales.objects.create(
                    customer=quotation.customer,
                    customer_name=quotation.customer_name or "Walk-in Customer",
                    customer_phone=quotation.customer_phone or "",
                    customer_email=quotation.customer_email or "",
                    subtotal=subtotal,
                    overall_discount=Decimal(str(quotation.discount_amount)),
                    tax_amount=Decimal(str(quotation.tax_amount)),
                    grand_total=Decimal(str(quotation.grand_total)),
                    amount_paid=Decimal('0.00'),
                    remaining_amount=Decimal(str(quotation.grand_total)),
                    is_fully_paid=False,
                    payment_method='CASH',
                    status='CONFIRMED',
                    date_of_sale=quotation.date_issued,
                    notes=quotation.description or "",
                    created_by=request.user
                )
                
                for item in quotation.items.all():
                    SaleItem.objects.create(
                        sale=sale,
                        product=item.product,
                        product_name=item.product.name if item.product else item.product_name,
                        quantity=item.quantity,
                        unit_price=Decimal(str(item.unit_price)),
                        line_total=Decimal(str(item.line_total)),
                        item_discount=Decimal('0.00')
                    )
            
            return Response({"detail": "Quotation successfully converted to Sale."})
        except Exception as e:
            logger.error(f"Error converting quotation to sale: {str(e)}", exc_info=True)
            return Response(
                {"detail": f"Error: {str(e)}"},
                status=status.HTTP_400_BAD_REQUEST
            )
