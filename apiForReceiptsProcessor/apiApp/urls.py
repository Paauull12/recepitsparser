from django.urls import path
from .views import ImgProcessor

urlpatterns = [
    path('process-image/', ImgProcessor.as_view(), name='process-image'),
]
