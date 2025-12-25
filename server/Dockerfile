# 1. Imagine de bază cu Python
FROM python:3.12-slim

# 2. Setăm directorul de lucru în container
WORKDIR /app

# 3. Copiem fișierele necesare
COPY requirements.txt .

# 4. Instalăm dependențele
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# 5. Copiem restul codului aplicației
COPY . .

# 6. Expunem portul pe care rulează FastAPI
EXPOSE 8000

# 7. Comanda de pornire FastAPI cu uvicorn
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]
