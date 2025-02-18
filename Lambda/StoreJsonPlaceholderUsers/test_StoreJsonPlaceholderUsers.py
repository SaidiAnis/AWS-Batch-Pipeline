import unittest
from unittest.mock import patch, MagicMock
import os
import json
from datetime import datetime
from StoreJsonPlaceholderUsers import lambda_handler # Ensure the filename is correct

class TestLambdaHandler(unittest.TestCase):

    @patch('StoreJsonPlaceholderUsers.requests.get')  # Mock for requests.get
    @patch('StoreJsonPlaceholderUsers.boto3.client')  # Mock for boto3.client
    def test_lambda_handler_success(self, mock_boto3_client, mock_requests_get):
        # Mock environment variable
        os.environ['S3_BUCKET'] = 'test-bucket'

        # Mock API response
        mock_response = MagicMock()
        mock_response.status_code = 200
        mock_response.json.return_value = [{"id": 1, "name": "John Doe"}]
        mock_requests_get.return_value = mock_response

        # Mock S3 client
        mock_s3_client = MagicMock()
        mock_boto3_client.return_value = mock_s3_client

        # Call lambda_handler function
        event = {}
        context = {}
        result = lambda_handler(event, context)

        # Assertions
        mock_requests_get.assert_called_once_with("https://jsonplaceholder.typicode.com/users")
        mock_boto3_client.assert_called_once_with('s3')

        # Verify filename
        date_today = datetime.now().strftime("%Y-%m-%d")
        expected_file_name = f"raw/users/jsonplaceholder_users_{date_today}.json"
        mock_s3_client.put_object.assert_called_once_with(
            Bucket='test-bucket',
            Key=expected_file_name,
            Body=json.dumps([{"id": 1, "name": "John Doe"}])
        )

        # Verify result
        self.assertEqual(result['statusCode'], 200)
        self.assertEqual(json.loads(result['body']), 'Data successfully stored in S3')

    @patch('StoreJsonPlaceholderUsers.requests.get')  # Mock for requests.get
    def test_lambda_handler_api_failure(self, mock_requests_get):
        # Mock environment variable
        os.environ['S3_BUCKET'] = 'test-bucket'

        # Mock API response to simulate failure
        mock_response = MagicMock()
        mock_response.status_code = 400
        mock_requests_get.return_value = mock_response

        # Call lambda_handler function
        event = {}
        context = {}
        result = lambda_handler(event, context)

        # Assertions
        mock_requests_get.assert_called_once_with("https://jsonplaceholder.typicode.com/users")

        # Verify result
        self.assertEqual(result['statusCode'], 400)
        self.assertEqual(json.loads(result['body']), 'Error calling the JSONPlaceholder API')

if __name__ == '__main__':
    unittest.main()