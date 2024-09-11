from django.shortcuts import render
from rest_framework import viewsets
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework import status
from django.core.files.base import ContentFile
from .service_image_processor import getInformationFromReceipt
import time
from rest_framework.parsers import MultiPartParser, FormParser
        

class ImgProcessor(APIView):
    parser_classes = (MultiPartParser, FormParser,)

    def get(self, request):
        return Response({'value': 1}, status=status.HTTP_200_OK)
    
    def post(self, request, *args, **kwargs):
        file_obj = request.FILES.get('image')

        if not file_obj:
            return Response({'error': 'No file found in request'}, status=status.HTTP_400_BAD_REQUEST)

        try:
            return Response({'value': getInformationFromReceipt(file_obj)}, status=status.HTTP_200_OK)
            time.sleep(50)
            return Response({'value':1}, status=status.HTTP_200_OK)
        except Exception as e:
            print(f"Error: {e}")
            return Response({'error': "An error occurred while processing the image." + str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
