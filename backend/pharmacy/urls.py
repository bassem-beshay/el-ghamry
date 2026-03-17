from django.urls import path, include
from rest_framework.routers import DefaultRouter
from . import views

router = DefaultRouter()
router.register('categories', views.CategoryViewSet)
router.register('products', views.ProductViewSet)
router.register('stock-logs', views.StockLogViewSet)
router.register('prescriptions', views.PrescriptionViewSet)

urlpatterns = [
    path('', include(router.urls)),
]
