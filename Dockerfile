# Dockerfile
# Download base image for Python applications
FROM python:3.8-alpine

# Install necessary libraries
RUN pip install flask

# Change working directory in the container
WORKDIR /app

# Copy local files into the container image
COPY server.py /app
COPY specification.yaml /app

# Configure the command to be executed in the container
# (Python application + script name as parameter)
ENTRYPOINT [ "python" ]
CMD ["server.py"]
