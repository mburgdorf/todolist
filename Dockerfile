# Dockerfile
# Basisimage für Python-Anwendungen herunterladen
FROM python:3.8-alpine

# Notwendige Bibliotheken installieren
RUN pip install flask

# Arbeitsverzeichnis im Container wechseln
WORKDIR /app

# Kopiere lokale Dateien in das Container-Image
COPY server.py /app
COPY specification.yaml /app

# Konfiguriere den Befehl, der im Container ausgeführt werden soll 
# (Anwendung Python + Skriptname als Parameter)
ENTRYPOINT [ "python" ]
CMD ["server.py"]
