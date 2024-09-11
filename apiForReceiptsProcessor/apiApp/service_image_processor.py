from transformers import DonutProcessor, VisionEncoderDecoderModel
from PIL import Image
from django.apps import apps
import re
import io
import time
import numpy as np

def replace_except_chars(s, chars_to_keep, replacement_char):
    pattern = f'[^{re.escape(chars_to_keep)}]'
    return re.sub(pattern, replacement_char, s)

def getNumber(stringThatIsAlMostAnumber):
    stringThatIsAlMostAnumber = stringThatIsAlMostAnumber.strip()
    stringThatIsAlMostAnumber = stringThatIsAlMostAnumber.replace(',','.')
    chars_to_keep = "1234567890."
    replace_with = ""
    return replace_except_chars(stringThatIsAlMostAnumber, chars_to_keep, replace_with)

def getInformationFromReceipt(img):
    config = apps.get_app_config("apiApp")
    processor, model = config.getProcMod()

    if hasattr(img, 'read'):
        img = img.read()  

    img = io.BytesIO(img)
    
    image = Image.open(img).convert("RGB")  

    pixel_values = processor(image, return_tensors="pt").pixel_values

    generated_ids = model.generate(pixel_values)

    output_text = processor.batch_decode(generated_ids, skip_special_tokens=True)[0]

    total = re.findall(r'<s_total>(.*?)</s_total>', output_text)

    if total:
        return getNumber(total[0])  
    else:
        return "Total not found"
