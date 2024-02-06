import hashlib


def generate_order_id(user_id: str) -> str:
    """Generate an order/order ID with the products for the user by hashing the user ID

    Args:
        user_id (str): user_id from the request body

    Returns:
        str: order_id generated from the user_id
    """
    hash_object = hashlib.sha256() # Create a new sha256 hash object
    hash_object.update(user_id.encode('utf-8')) # Update the hash object with the bytes of the input text
    hash_hex = hash_object.hexdigest() # Get the hexadecimal representation of the hash
    order_id = f"order_{hash_hex}"
    return order_id
