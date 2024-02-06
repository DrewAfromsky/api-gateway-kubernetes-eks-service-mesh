from flask import Flask, request, jsonify
from utils import generate_order_id


app = Flask(__name__)


@app.route('/orders', methods=['POST'])
def create_order():
    order_data = request.json
    
    order_id = generate_order_id(
        user_id=order_data.get('user_id')
    )
    
    order_data['order_id'] = order_id

    return jsonify(
        {
            'message': f'Order {order_data.get("order_id")} created successfully', 
            'order_data': order_data
        }
    ), 201

if __name__ == '__main__':
    app.run(
        host="0.0.0.0",
        port=5002,
        debug=True
    )