from django.contrib import admin
from .models import Category, Product, StockLog, Prescription, PrescriptionItem


@admin.register(Category)
class CategoryAdmin(admin.ModelAdmin):
    list_display = ('name', 'created_at')
    search_fields = ('name',)


@admin.register(Product)
class ProductAdmin(admin.ModelAdmin):
    list_display = ('name', 'category', 'price', 'stock', 'requires_prescription', 'expiry_date')
    list_filter = ('category', 'requires_prescription')
    search_fields = ('name', 'barcode', 'manufacturer')
    list_editable = ('price', 'stock')


@admin.register(StockLog)
class StockLogAdmin(admin.ModelAdmin):
    list_display = ('product', 'action', 'quantity', 'note', 'created_at')
    list_filter = ('action', 'created_at')
    search_fields = ('product__name',)


class PrescriptionItemInline(admin.TabularInline):
    model = PrescriptionItem
    extra = 1
    autocomplete_fields = ['product']


@admin.register(Prescription)
class PrescriptionAdmin(admin.ModelAdmin):
    list_display = ('patient_name', 'patient_phone', 'doctor_name', 'total_price', 'created_at')
    search_fields = ('patient_name', 'patient_phone', 'doctor_name')
    list_filter = ('created_at',)
    inlines = [PrescriptionItemInline]
