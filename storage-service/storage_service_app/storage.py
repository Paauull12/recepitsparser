# storage_backends.py
from storages.backends.s3boto3 import S3Boto3Storage
from minio import Minio
from django.conf import settings
import os

class MinioStorage(S3Boto3Storage):
    access_key = os.environ.get('MINIO_ACCESS_KEY')
    secret_key = os.environ.get('MINIO_SECRET_KEY')
    bucket_name = 'bucket01'
    endpoint_url = os.environ.get('MINIO_ENDPOINT')
    
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.client = Minio(
            self.endpoint_url.split('//')[1],
            access_key=self.access_key,
            secret_key=self.secret_key,
            secure=False  # Set to True if using HTTPS
        )
        
        # Ensure the bucket exists
        if not self.client.bucket_exists(self.bucket_name):
            self.client.make_bucket(self.bucket_name)

    def url(self, name):
        return f"{self.endpoint_url}/{self.bucket_name}/{name}"
