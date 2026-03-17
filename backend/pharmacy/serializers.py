from rest_framework import serializers
from .models import Category, Product, StockLog, Prescription, PrescriptionItem


class CategorySerializer(serializers.ModelSerializer):
    product_count = serializers.IntegerField(source='products.count', read_only=True)

    class Meta:
        model = Category
        fields = '__all__'


class ProductSerializer(serializers.ModelSerializer):
    category_name = serializers.CharField(source='category.name', read_only=True)
    is_out_of_stock = serializers.BooleanField(read_only=True)
    is_low_stock = serializers.BooleanField(read_only=True)

    class Meta:
        model = Product
        fields = '__all__'


class StockUpdateSerializer(serializers.Serializer):
    """سيريالايزر لتعديل الكمية (إضافة أو خصم)"""
    action = serializers.ChoiceField(choices=['add', 'remove'])
    quantity = serializers.IntegerField(min_value=1)
    note = serializers.CharField(required=False, default='')


class StockLogSerializer(serializers.ModelSerializer):
    product_name = serializers.CharField(source='product.name', read_only=True)

    class Meta:
        model = StockLog
        fields = '__all__'


class PrescriptionItemSerializer(serializers.ModelSerializer):
    product_name = serializers.CharField(source='product.name', read_only=True)
    product_price = serializers.DecimalField(source='product.price', max_digits=10, decimal_places=2, read_only=True)
    total = serializers.DecimalField(max_digits=10, decimal_places=2, read_only=True)

    class Meta:
        model = PrescriptionItem
        fields = ['id', 'product', 'product_name', 'product_price', 'quantity', 'dosage', 'duration', 'total']


class PrescriptionSerializer(serializers.ModelSerializer):
    items = PrescriptionItemSerializer(many=True, read_only=True)
    total_price = serializers.DecimalField(max_digits=10, decimal_places=2, read_only=True)

    class Meta:
        model = Prescription
        fields = '__all__'


class PrescriptionCreateSerializer(serializers.ModelSerializer):
    """سيريالايزر لإنشاء روشتة مع الأدوية"""
    items = PrescriptionItemSerializer(many=True)

    class Meta:
        model = Prescription
        fields = '__all__'

    def create(self, validated_data):
        items_data = validated_data.pop('items')
        prescription = Prescription.objects.create(**validated_data)
        for item_data in items_data:
            PrescriptionItem.objects.create(prescription=prescription, **item_data)
        return prescription

    def update(self, instance, validated_data):
        items_data = validated_data.pop('items', None)
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        instance.save()

        if items_data is not None:
            instance.items.all().delete()
            for item_data in items_data:
                PrescriptionItem.objects.create(prescription=instance, **item_data)

        return instance
