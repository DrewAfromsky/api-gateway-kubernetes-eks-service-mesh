from flask import Flask, request, jsonify
import requests
from utils import generate_user_id


app = Flask(__name__)


@app.route('/users', methods=['POST'])
def create_user():
    user_data = request.json  # Get user data from the request
    
    user_id = generate_user_id(
        username=user_data.get('username')
    )

    # Add the user ID to the user data
    user_data['user_id'] = user_id

    products = requests.get('http://products-service:5001/products').json()  # Send GET request to products-service using the user data
    
    # Send POST request to orders-service to make an order with products for the user
    order_response = requests.post(
        'http://orders-service:5002/orders', 
        json={
            'user': user_data,
            'products': products
        }
    )
    return jsonify(
        {
            'message': f'User created {user_data.get("user_id")} successfully',
            'orders_response': orders_response.json()
        }
    ), 201

if __name__ == '__main__':
    app.run(
        host="0.0.0.0", 
        port=5000, 
        debug=True
    )