import easyocr
import cv2
import re
import regex
import numpy as np
from PIL import Image
from io import BytesIO
from django.core.files.base import ContentFile

def replace_except_chars(s, chars_to_keep, replacement_char):
    pattern = f'[^{re.escape(chars_to_keep)}]'
    return re.sub(pattern, replacement_char, s)

def getNumber(stringThatIsAlMostAnumber):
    stringThatIsAlMostAnumber = stringThatIsAlMostAnumber.strip()
    stringThatIsAlMostAnumber = stringThatIsAlMostAnumber.replace(',', '.')
    chars_to_keep = "1234567890."
    replace_with = ""
    return replace_except_chars(stringThatIsAlMostAnumber, chars_to_keep, replace_with)

def resultIsTotal(text):
    formattedText = text.strip().lower()

    possibleResults = [
        # English
        "total", "balance", "net total", "payment", "amount",
        
        # French
        "total", "solde", "total net", "paiement", "montant",

        # Spanish
        "total", "saldo", "total neto", "pago", "cantidad",

        # German
        "gesamt", "saldo", "nettobetrag", "zahlung", "betrag",

        # Italian
        "totale", "saldo", "totale netto", "pagamento", "importo",

        # Portuguese
        "total", "saldo", "total líquido", "pagamento", "quantia",

        # Dutch
        "totaal", "saldo", "netto totaal", "betaling", "bedrag",

        # Swedish
        "total", "saldo", "nettobelopp", "betalning", "belopp"
    ]

    for result in possibleResults:
        max_errors = max(1, len(result) // 3) 
        if regex.search(f'({result}){{e<={max_errors}}}', formattedText):
            return True

    return False

def findTextOnTheSameLine(thetotalword, word):
    """
    Checks if the bounding box of a text is on the same line with another bounding box while considering a
    dynamically chosen vertical offset error.
    """
    bbox = np.array(thetotalword, dtype=np.int32)
    firsty = bbox[0][1]
    secondy = bbox[3][1]

    bbox = np.array(word, dtype=np.int32)
    newfirsty = bbox[0][1]
    newsecondy = bbox[3][1]

    c = (secondy - firsty) / 2

    return abs(firsty-newfirsty) < c or abs(secondy-newsecondy) < c

def imageParserWithEasyOcr(content_file):

    if isinstance(content_file, ContentFile):
        img_bytes = content_file.read()
    else:
        img_bytes = content_file
    
    img_pil = Image.open(BytesIO(img_bytes))

    img_np = np.array(img_pil)

    if len(img_np.shape) == 2: 
        img_np = cv2.cvtColor(img_np, cv2.COLOR_GRAY2BGR)

    reader = easyocr.Reader(['en'])  
    print("am ajuns aici1")

    results = reader.readtext(img_np, width_ths=10000, min_size=5, link_threshold=0.1)
    print("am ajuns aici2")

    listOfTotals = [result for result in results if resultIsTotal(result[1])]

    print(listOfTotals)

    listOfPrices = []
    for result in listOfTotals:
        for words in results:
            if findTextOnTheSameLine(result[0], words[0]) and result != words:
                number = getNumber(words[1])
                print(number)
                if(number):
                    listOfPrices.append(float(getNumber(words[1])))

    for item in listOfTotals:
        number = getNumber(item[1])
        if number:
            listOfPrices.append(float(number))
    return max(listOfPrices)


