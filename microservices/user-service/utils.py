import hashlib


def generate_user_id(username: str) -> str:
    """Generate a user ID by hashing the username provided in the request data

    Args:
        username (str): username from the request body

    Returns:
        str: user_id generated from the username
    """
    hash_object = hashlib.sha256() # Create a new sha256 hash object
    hash_object.update(username.encode('utf-8')) # Update the hash object with the bytes of the input text
    hash_hex = hash_object.hexdigest() # Get the hexadecimal representation of the hash
    user_id = f"user_{hash_hex}"
    return user_id