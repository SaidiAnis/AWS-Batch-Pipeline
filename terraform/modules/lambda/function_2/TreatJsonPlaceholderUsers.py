import os
import json
import boto3

def flatten_user(user):
    """
    Flattens the JSON structure of a user.
    """
    flattened = {
        "id": user.get("id"),
        "name": user.get("name"),
        "username": user.get("username"),
        "email": user.get("email"),
        "address_street": user.get("address", {}).get("street"),
        "address_suite": user.get("address", {}).get("suite"),
        "address_city": user.get("address", {}).get("city"),
        "address_zipcode": user.get("address", {}).get("zipcode"),
        "address_geo_lat": user.get("address", {}).get("geo", {}).get("lat"),
        "address_geo_lng": user.get("address", {}).get("geo", {}).get("lng"),
        "phone": user.get("phone"),
        "website": user.get("website"),
        "company_name": user.get("company", {}).get("name"),
        "company_catchPhrase": user.get("company", {}).get("catchPhrase"),
        "company_bs": user.get("company", {}).get("bs")
    }
    return flattened

def lambda_handler(event, context):
    # Get the bucket name from environment variables
    s3_bucket = os.environ.get("S3_BUCKET")
    if not s3_bucket:
        return {"statusCode": 500, "body": "S3_BUCKET environment variable is not set"}
    
    s3 = boto3.client('s3')
    processed_prefix = "processed/users/"
    
    # Extract file name from the S3 event
    records = event.get("Records", [])
    for record in records:
        s3_info = record.get("s3", {})
        bucket_name = s3_info.get("bucket", {}).get("name", "")
        file_key = s3_info.get("object", {}).get("key", "")
        
        # Check if the file is in the "raw/users/" folder
        if not file_key.startswith("raw/users/"):
            continue
        
        print(f"Processing file: {file_key}")
        
        # Read the file from S3
        try:
            file_obj = s3.get_object(Bucket=bucket_name, Key=file_key)
            file_content = file_obj["Body"].read().decode("utf-8")
            data = json.loads(file_content)
        except Exception as e:
            return {"statusCode": 500, "body": f"Error reading file from S3: {str(e)}"}

        # Flatten each user
        flattened_data = [flatten_user(user) for user in data]

        # Keep only users with ID < 5
        processed_data = [user for user in flattened_data if user.get("id", 0) < 5]
        
        # Generate a new file name
        original_filename = file_key.split("/")[-1]  # Extract the original file name
        new_file_key = f"{processed_prefix}processed_{original_filename}"  # Add 'processed_' prefix
        
        # Convert data to JSON Lines format (one object per line)
        json_lines = "\n".join([json.dumps(user) for user in processed_data])
        
        # Save the processed data to S3
        try:
            s3.put_object(
                Bucket=s3_bucket,
                Key=new_file_key,
                Body=json_lines
            )
        except Exception as e:
            return {"statusCode": 500, "body": f"Error writing file to S3: {str(e)}"}
        
    return {"statusCode": 200, "body": "Data processed, flattened, and saved in JSON Lines format"}
