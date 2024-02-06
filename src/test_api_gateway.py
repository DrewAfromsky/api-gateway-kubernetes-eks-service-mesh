import requests
import concurrent.futures
import time

# API endpoint
API_ENDPOINT = "https://your-api-id.execute-api.your-region.amazonaws.com/prod/orders"

# Function to send a POST request
def send_request():
    response = requests.post(API_ENDPOINT, json={"order": "details"})
    return response.status_code

# Simulate requests
def simulate_requests(requests_per_second, duration_seconds):
    with concurrent.futures.ThreadPoolExecutor(max_workers=requests_per_second) as executor:
        start_time = time.time()
        while time.time() - start_time < duration_seconds:
            futures = [executor.submit(send_request) for _ in range(requests_per_second)]
            concurrent.futures.wait(futures)
            print(f"Sent {requests_per_second} requests...")
            time.sleep(1)  # Wait for a second before the next batch

# Normal operation
print("Starting normal operation...")
simulate_requests(50, 10)

# Burst traffic
print("Simulating burst traffic...")
simulate_requests(25, 10)

# Over limit
print("Testing over limit...")
simulate_requests(150, 15)
