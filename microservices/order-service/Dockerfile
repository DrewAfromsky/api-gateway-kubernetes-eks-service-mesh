# Create a layer from the Python 3.10 image
FROM python:3.10 as order-service

# Keeps Python from buffering stdout and stderr to avoid situations where
# the application crashes without emitting any logs due to buffering.
ENV PYTHONUNBUFFERED=1

# Define the network ports that this container will listen on at runtime.
EXPOSE 5002

# Set the current working directory to /app.
# WORKDIR /app

# Copy the file with the requirements to the /app directory.
COPY ./requirements.txt . 

# Install the package dependencies defined in the requirements file.
# The --no-cache-dir option tells pip to not save the downloaded packages locally.
# The --upgrade option tells pip to upgrade the packages if they are already installed.
RUN pip3 install --no-cache-dir --upgrade -r requirements.txt
# RUN pip3 install gunicorn

# Copy the files inside of source code directory "src" inside the /app directory.
COPY . . 

CMD ["python3", "app.py"]
# CMD ["gunicorn", "-w", "4", "app:app", "-b", "0.0.0.0:5000"]

# Create a new target called test that will run the test suite
# FROM order-service as test
# CMD ["python3", "-m", "pytest", "-vv", "/app/src/tests/test_main.py", "--disable-warnings"]