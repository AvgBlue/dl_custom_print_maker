#01000010276

import requests

def send_post_request(id_value):
    # Replace <id> dynamically in the URL
    url = f"https://orchis.cherrymint.live/savedata.json?id={id_value}"

    # Optional: If you want to send additional data in the POST request body
    data = {
        # Add any additional data you want to send
    }

    try:
        # Sending the POST request
        response = requests.get(url, json=data)
        
        # Printing the full response information
        print("Status Code:", response.status_code)
        print("Response Headers:", response.headers)
        
        # Try to print the response as JSON, otherwise print as text
        try:
            response_json = response.json()
            print("Response Body (JSON):", response_json)
        except ValueError:  # If response is not in JSON format
            print("Response Body (Text):", response.text)
    
    except requests.exceptions.HTTPError as http_err:
        print(f"HTTP error occurred: {http_err}")
    except requests.exceptions.RequestException as req_err:
        print(f"Error occurred: {req_err}")

# Example usage with a specific ID
send_post_request("1234")  # Replace '12345' with the actual ID you want to use
