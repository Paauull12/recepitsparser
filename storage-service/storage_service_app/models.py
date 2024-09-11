from django.db import models
from datetime import datetime

class Image(models.Model):
    image = models.ImageField(upload_to='')
    minio_url = models.URLField(max_length=255, blank=True, null=True)
    uploaded_at = models.DateTimeField(default=datetime.now)

    def __str__(self):
        return self.image.name

    class Meta:
        db_table = 'Images'

    def save(self, *args, **kwargs):
        if not self.pk:  # Only set the URL if this is a new object
            super().save(*args, **kwargs)
            if self.image:
                self.minio_url = self.image.url
                super().save(update_fields=['minio_url'])
        else:
            super().save(*args, **kwargs)