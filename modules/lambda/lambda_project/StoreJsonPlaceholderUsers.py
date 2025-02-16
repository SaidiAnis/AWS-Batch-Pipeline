import os
import json
import requests
import boto3
from datetime import datetime

def lambda_handler(event, context):
    # Get the bucket name from environment variables
    s3_bucket = os.environ['S3_BUCKET']  # This gets the value of the S3_BUCKET environment variable

    # URL of the JSONPlaceholder API
    api_url = "https://jsonplaceholder.typicode.com/users"
    response = requests.get(api_url)

    if response.status_code == 200:
        data = response.json()

        # Prepare data to store
        date_today = datetime.now().strftime("%Y-%m-%d")
        file_name = f"raw/users/jsonplaceholder_users_{date_today}.json"

        # Save users data to S3
        s3 = boto3.client('s3')
        s3.put_object(Bucket=s3_bucket, Key=file_name, Body=json.dumps(data))

        return {
            'statusCode': 200,
            'body': json.dumps('Data successfully stored in S3')
        }
    else:
        return {
            'statusCode': 400,
            'body': json.dumps('Error calling the JSONPlaceholder API')
        }
