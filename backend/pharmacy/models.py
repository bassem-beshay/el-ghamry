from django.db import models


class Category(models.Model):
    name = models.CharField(max_length=200, verbose_name='اسم الفئة')
    description = models.TextField(blank=True, verbose_name='الوصف')
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        verbose_name = 'فئة'
        verbose_name_plural = 'الفئات'

    def __str__(self):
        return self.name


class Product(models.Model):
    name = models.CharField(max_length=300, verbose_name='اسم المنتج')
    category = models.ForeignKey(Category, on_delete=models.CASCADE, related_name='products', verbose_name='الفئة')
    description = models.TextField(blank=True, verbose_name='الوصف')
    price = models.DecimalField(max_digits=10, decimal_places=2, verbose_name='السعر')
    stock = models.PositiveIntegerField(default=0, verbose_name='المخزون')
    image = models.ImageField(upload_to='products/', blank=True, null=True, verbose_name='الصورة')
    barcode = models.CharField(max_length=100, blank=True, verbose_name='الباركود')
    requires_prescription = models.BooleanField(default=False, verbose_name='يحتاج وصفة طبية')
    expiry_date = models.DateField(null=True, blank=True, verbose_name='تاريخ الصلاحية')
    manufacturer = models.CharField(max_length=300, blank=True, verbose_name='الشركة المصنعة')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = 'منتج'
        verbose_name_plural = 'المنتجات'
        ordering = ['-updated_at']

    def __str__(self):
        return f"{self.name} (الكمية: {self.stock})"

    @property
    def is_out_of_stock(self):
        return self.stock == 0

    @property
    def is_low_stock(self):
        return 0 < self.stock <= 10


class StockLog(models.Model):
    """سجل حركة المخزون - كل عملية إضافة أو خصم"""
    ACTION_CHOICES = [
        ('add', 'إضافة'),
        ('remove', 'خصم'),
    ]
    product = models.ForeignKey(Product, on_delete=models.CASCADE, related_name='stock_logs', verbose_name='المنتج')
    action = models.CharField(max_length=10, choices=ACTION_CHOICES, verbose_name='نوع العملية')
    quantity = models.PositiveIntegerField(verbose_name='الكمية')
    note = models.TextField(blank=True, verbose_name='ملاحظة')
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        verbose_name = 'حركة مخزون'
        verbose_name_plural = 'حركات المخزون'
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.get_action_display()} {self.quantity} من {self.product.name}"


class Prescription(models.Model):
    """الروشتة الطبية"""
    patient_name = models.CharField(max_length=300, verbose_name='اسم المريض')
    patient_phone = models.CharField(max_length=20, blank=True, verbose_name='رقم تليفون المريض')
    doctor_name = models.CharField(max_length=300, blank=True, verbose_name='اسم الدكتور')
    image = models.ImageField(upload_to='prescriptions/', blank=True, null=True, verbose_name='صورة الروشتة')
    notes = models.TextField(blank=True, verbose_name='ملاحظات')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = 'روشتة'
        verbose_name_plural = 'الروشتات'
        ordering = ['-created_at']

    def __str__(self):
        return f"روشتة {self.patient_name} - {self.created_at.strftime('%Y-%m-%d')}"

    @property
    def total_price(self):
        return sum(item.total for item in self.items.all())


class PrescriptionItem(models.Model):
    """عنصر في الروشتة - الدوا الفعلي"""
    prescription = models.ForeignKey(Prescription, on_delete=models.CASCADE, related_name='items', verbose_name='الروشتة')
    product = models.ForeignKey(Product, on_delete=models.CASCADE, related_name='prescription_items', verbose_name='الدواء')
    quantity = models.PositiveIntegerField(default=1, verbose_name='الكمية')
    dosage = models.CharField(max_length=300, blank=True, verbose_name='الجرعة', help_text='مثال: قرص كل 8 ساعات')
    duration = models.CharField(max_length=200, blank=True, verbose_name='المدة', help_text='مثال: 7 أيام')

    class Meta:
        verbose_name = 'عنصر روشتة'
        verbose_name_plural = 'عناصر الروشتة'

    def __str__(self):
        return f"{self.product.name} × {self.quantity}"

    @property
    def total(self):
        return self.product.price * self.quantity
