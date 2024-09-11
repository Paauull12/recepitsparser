from datetime import datetime
from django.core.files.storage import default_storage
from django.core.files.base import ContentFile
from rest_framework.parsers import MultiPartParser, FormParser
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework import status
from .models import Image
import requests
import logging 
import json
from .service_easyocr import imageParserWithEasyOcr

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class ImageUploadAPI(APIView):
    parser_classes = (MultiPartParser, FormParser,)

    def post(self, request, *args, **kwargs):
        """
        Store Image API Endpoint

        This endpoint allows users to upload an image file and store it in both the database and MinIO S3-compatible storage.

        Method: POST
        Endpoint: /api/store/
        Content-Type: multipart/form-data

        Request:
        - file: The image file to be uploaded (required)

        Response:
        - 201 Created: Image uploaded successfully
          {
            "message": "Image stored successfully",
            "image_url": "http://minio:9000/images/filename.jpg"
          }
        - 400 Bad Request: No file in request or upload failed
          {
            "error": "Error message"
          }

        Example usage with curl:
        curl -X POST http://localhost:8000/api/store/ \
          -H 'Content-Type: multipart/form-data' \
          -F 'file=@/path/to/your/image.jpg'

        Notes:
        - Ensure the MinIO server is running and accessible.
        - The image will be stored in the MinIO 'images' bucket.
        - The Image model will store metadata about the uploaded image, including its MinIO URL.
        """

        file_obj = request.FILES.get('file')
    
        if not file_obj:
            logger.warning("No file found in request")
            return Response({'error': 'No file found in request'}, status=status.HTTP_400_BAD_REQUEST)

        try:
            file_content = file_obj.read()
            file_contents_aux = file_content

            file_contents = ContentFile(file_content)

            filename = f"{datetime.now().strftime('%Y%m%d%H%M%S')}_{file_obj.name}"

            file_path = default_storage.save(filename, file_contents)

            image_instance = Image.objects.create(image=file_path)
            logger.info(f"File saved to path: {file_path}")

            result12 = ""
            try:
                result12 = imageParserWithEasyOcr(file_contents_aux)
                
                print(result12)
            except Exception as e:
                print(f"We have an error with easyocr {e}")
            
            req = self._process_image_with_text_detect_api(file_content)
            
            logger.info("Image upload process completed successfully")

            response_data = req.json()
            rezult = ""
            rezult = response_data.get('value', "11.50")

            return Response({
                'message': 'Image stored successfully',
                'total': f"Donut Ai: {rezult} | EasyOcr + regex: {result12}",
                'image_url': image_instance.minio_url
            }, status=status.HTTP_201_CREATED)

        except Exception as e:
            logger.error(f"Failed to upload image: {str(e)}", exc_info=True)
            return Response({'error': f'Failed to upload image: {str(e)}'}, status=status.HTTP_400_BAD_REQUEST)

    def _process_image_with_text_detect_api(self, file_content):
        try:
            logger.info("Sending image to text detection API")
            response = requests.post(
                "http://textdetectapi:80/api/process-image/",
                files={'image': file_content},
            )
            response.raise_for_status()
            logger.info(f"Text detection API response: {response.json()}")
            return response
        except requests.RequestException as e:
            logger.error(f"Error calling text detection API: {str(e)}", exc_info=True)
