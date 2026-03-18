from django.core.management.base import BaseCommand
from pharmacy.models import Category, Product, Prescription, PrescriptionItem
from pharmacy.seed_data.categories import CATEGORIES
from pharmacy.seed_data.products import PRODUCTS
from pharmacy.seed_data.prescriptions import PRESCRIPTIONS
from datetime import date


class Command(BaseCommand):
    help = 'تعبئة قاعدة البيانات بالأدوية والروشتات'

    def handle(self, *args, **options):
        self.stdout.write('جاري حذف البيانات القديمة...')
        PrescriptionItem.objects.all().delete()
        Prescription.objects.all().delete()
        Product.objects.all().delete()
        Category.objects.all().delete()

        # 1. إنشاء الأقسام
        self.stdout.write('جاري إنشاء الأقسام...')
        category_map = {}
        for cat_data in CATEGORIES:
            cat = Category.objects.create(
                name=cat_data['name'],
                description=cat_data['description'],
            )
            category_map[cat.name] = cat
            self.stdout.write(f'  + {cat.name}')
        self.stdout.write(self.style.SUCCESS(f'تم إنشاء {len(category_map)} قسم'))

        # 2. إنشاء المنتجات
        self.stdout.write('جاري إنشاء المنتجات...')
        product_map = {}
        created = 0
        for prod_data in PRODUCTS:
            category = category_map.get(prod_data['category'])
            if not category:
                self.stdout.write(self.style.WARNING(f'  ! قسم غير موجود: {prod_data["category"]} للمنتج {prod_data["name"]}'))
                continue

            expiry = None
            if prod_data.get('expiry_date'):
                try:
                    expiry = date.fromisoformat(prod_data['expiry_date'])
                except (ValueError, TypeError):
                    pass

            product = Product.objects.create(
                name=prod_data['name'],
                category=category,
                description=prod_data.get('description', ''),
                price=prod_data['price'],
                stock=prod_data.get('stock', 50),
                barcode=prod_data.get('barcode', ''),
                requires_prescription=prod_data.get('requires_prescription', False),
                manufacturer=prod_data.get('manufacturer', ''),
                expiry_date=expiry,
            )
            product_map[product.name] = product
            created += 1

        self.stdout.write(self.style.SUCCESS(f'تم إنشاء {created} منتج'))

        # 3. إنشاء الروشتات
        self.stdout.write('جاري إنشاء الروشتات...')
        rx_created = 0
        items_created = 0
        for rx_data in PRESCRIPTIONS:
            prescription = Prescription.objects.create(
                patient_name=rx_data['patient_name'],
                patient_phone=rx_data.get('patient_phone', ''),
                doctor_name=rx_data.get('doctor_name', ''),
                notes=rx_data.get('notes', ''),
            )
            rx_created += 1

            for item_data in rx_data.get('items', []):
                product = product_map.get(item_data['product_name'])
                if not product:
                    self.stdout.write(self.style.WARNING(
                        f'  ! دوا غير موجود: {item_data["product_name"]} في روشتة {rx_data["patient_name"]}'
                    ))
                    continue

                PrescriptionItem.objects.create(
                    prescription=prescription,
                    product=product,
                    quantity=item_data.get('quantity', 1),
                    dosage=item_data.get('dosage', ''),
                    duration=item_data.get('duration', ''),
                )
                items_created += 1

        self.stdout.write(self.style.SUCCESS(f'تم إنشاء {rx_created} روشتة بإجمالي {items_created} عنصر'))
        self.stdout.write(self.style.SUCCESS('تم تعبئة قاعدة البيانات بنجاح!'))
