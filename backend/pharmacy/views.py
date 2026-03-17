from rest_framework import viewsets, status, filters
from rest_framework.decorators import action
from rest_framework.response import Response
from django.db.models import Q
from .models import Category, Product, StockLog, Prescription, PrescriptionItem
from .serializers import (
    CategorySerializer, ProductSerializer,
    StockUpdateSerializer, StockLogSerializer,
    PrescriptionSerializer, PrescriptionCreateSerializer,
    PrescriptionItemSerializer,
)


class CategoryViewSet(viewsets.ModelViewSet):
    queryset = Category.objects.all()
    serializer_class = CategorySerializer
    filter_backends = [filters.SearchFilter]
    search_fields = ['name']


class ProductViewSet(viewsets.ModelViewSet):
    queryset = Product.objects.select_related('category').all()
    serializer_class = ProductSerializer
    filter_backends = [filters.SearchFilter, filters.OrderingFilter]
    search_fields = ['name', 'barcode', 'manufacturer']
    ordering_fields = ['name', 'price', 'stock', 'created_at']

    def get_queryset(self):
        queryset = super().get_queryset()
        category_id = self.request.query_params.get('category')
        stock_status = self.request.query_params.get('stock_status')

        if category_id:
            queryset = queryset.filter(category_id=category_id)
        if stock_status == 'out':
            queryset = queryset.filter(stock=0)
        elif stock_status == 'low':
            queryset = queryset.filter(stock__gt=0, stock__lte=10)
        elif stock_status == 'available':
            queryset = queryset.filter(stock__gt=10)

        return queryset

    @action(detail=True, methods=['post'], url_path='update-stock')
    def update_stock(self, request, pk=None):
        """إضافة أو خصم كمية من منتج معين"""
        product = self.get_object()
        serializer = StockUpdateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        action_type = serializer.validated_data['action']
        quantity = serializer.validated_data['quantity']
        note = serializer.validated_data.get('note', '')

        if action_type == 'add':
            product.stock += quantity
        elif action_type == 'remove':
            if quantity > product.stock:
                return Response(
                    {'error': f'الكمية المطلوبة ({quantity}) أكبر من المخزون الحالي ({product.stock})'},
                    status=status.HTTP_400_BAD_REQUEST,
                )
            product.stock -= quantity

        product.save()

        StockLog.objects.create(
            product=product,
            action=action_type,
            quantity=quantity,
            note=note,
        )

        return Response(ProductSerializer(product).data)

    @action(detail=True, methods=['get'], url_path='stock-logs')
    def stock_logs(self, request, pk=None):
        """عرض سجل حركة المخزون لمنتج معين"""
        product = self.get_object()
        logs = product.stock_logs.all()
        serializer = StockLogSerializer(logs, many=True)
        return Response(serializer.data)

    @action(detail=False, methods=['get'], url_path='summary')
    def summary(self, request):
        """ملخص المخزون"""
        total = Product.objects.count()
        out_of_stock = Product.objects.filter(stock=0).count()
        low_stock = Product.objects.filter(stock__gt=0, stock__lte=10).count()
        return Response({
            'total_products': total,
            'out_of_stock': out_of_stock,
            'low_stock': low_stock,
            'available': total - out_of_stock - low_stock,
        })


class StockLogViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = StockLog.objects.select_related('product').all()
    serializer_class = StockLogSerializer


class PrescriptionViewSet(viewsets.ModelViewSet):
    queryset = Prescription.objects.prefetch_related('items__product').all()
    filter_backends = [filters.SearchFilter, filters.OrderingFilter]
    search_fields = ['patient_name', 'patient_phone', 'doctor_name']
    ordering_fields = ['created_at', 'patient_name']

    def get_serializer_class(self):
        if self.action in ['create', 'update', 'partial_update']:
            return PrescriptionCreateSerializer
        return PrescriptionSerializer

    @action(detail=True, methods=['post'], url_path='add-item')
    def add_item(self, request, pk=None):
        """إضافة دوا للروشتة"""
        prescription = self.get_object()
        serializer = PrescriptionItemSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        serializer.save(prescription=prescription)
        return Response(
            PrescriptionSerializer(prescription).data,
            status=status.HTTP_201_CREATED,
        )

    @action(detail=True, methods=['delete'], url_path='remove-item/(?P<item_id>[0-9]+)')
    def remove_item(self, request, pk=None, item_id=None):
        """حذف دوا من الروشتة"""
        prescription = self.get_object()
        try:
            item = prescription.items.get(id=item_id)
        except PrescriptionItem.DoesNotExist:
            return Response(
                {'error': 'العنصر غير موجود في الروشتة'},
                status=status.HTTP_404_NOT_FOUND,
            )
        item.delete()
        return Response(PrescriptionSerializer(prescription).data)
