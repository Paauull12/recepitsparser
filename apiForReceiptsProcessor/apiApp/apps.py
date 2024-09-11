from django.apps import AppConfig
import threading
import json
from django.apps import AppConfig
from transformers import DonutProcessor, VisionEncoderDecoderModel 
from pathlib import Path

class ApiappConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'apiApp'
    model = None
    processor = None  
    _model_lock = threading.Lock() 

    def getProcMod(self):
        return self.processor, self.model

    def ready(self):
        t = threading.Thread(target=self._load_model)
        t.start()
        t.join()

    def _load_model(self):
        with self._model_lock: 
            if self.processor is None or self.model is None:  
                try:
                    model_name = "mychen76/invoice-and-receipts_donut_v1"
                    
                    self.processor = DonutProcessor.from_pretrained(model_name)
                    self.model = VisionEncoderDecoderModel.from_pretrained(model_name)
                    self.model.eval()  
                    
                except Exception as e:
                    print(f"Error loading model: {e}")
                    self.processor = None
                    self.model = None

 