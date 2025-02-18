import unittest
from unittest.mock import patch, MagicMock
import os
import json
from ProcessJsonPlaceholderUsers import lambda_handler, flatten_user

class TestLambdaFunction(unittest.TestCase):

    def test_flatten_user(self):
        # Test the flatten_user function
        user = {
            "id": 1,
            "name": "Leanne Graham",
            "username": "Bret",
            "email": "Sincere@april.biz",
            "address": {
                "street": "Kulas Light",
                "suite": "Apt. 556",
                "city": "Gwenborough",
                "zipcode": "92998-3874",
                "geo": {
                    "lat": "-37.3159",
                    "lng": "81.1496"
                }
            },
            "phone": "1-770-736-8031 x56442",
            "website": "hildegard.org",
            "company": {
                "name": "Romaguera-Crona",
                "catchPhrase": "Multi-layered client-server neural-net",
                "bs": "harness real-time e-markets"
            }
        }

        expected_flattened = {
            "id": 1,
            "name": "Leanne Graham",
            "username": "Bret",
            "email": "Sincere@april.biz",
            "address_street": "Kulas Light",
            "address_suite": "Apt. 556",
            "address_city": "Gwenborough",
            "address_zipcode": "92998-3874",
            "address_geo_lat": "-37.3159",
            "address_geo_lng": "81.1496",
            "phone": "1-770-736-8031 x56442",
            "website": "hildegard.org",
            "company_name": "Romaguera-Crona",
            "company_catchPhrase": "Multi-layered client-server neural-net",
            "company_bs": "harness real-time e-markets"
        }

        result = flatten_user(user)
        self.assertEqual(result, expected_flattened)

    @patch('ProcessJsonPlaceholderUsers.boto3.client')
    def test_lambda_handler_success(self, mock_boto3_client):
        # Configure mocks
        os.environ['S3_BUCKET'] = 'test-bucket'

        # Mock S3 event
        event = {
            "Records": [
                {
                    "s3": {
                        "bucket": {"name": "test-bucket"},
                        "object": {"key": "raw/users/users.json"}
                    }
                }
            ]
        }

        # Mock S3 response (JSON file)
        mock_s3_client = MagicMock()
        mock_boto3_client.return_value = mock_s3_client
        mock_s3_client.get_object.return_value = {
            "Body": MagicMock(read=MagicMock(return_value=json.dumps([
                {
                    "id": 1,
                    "name": "Leanne Graham",
                    "username": "Bret",
                    "email": "Sincere@april.biz",
                    "address": {
                        "street": "Kulas Light",
                        "suite": "Apt. 556",
                        "city": "Gwenborough",
                        "zipcode": "92998-3874",
                        "geo": {
                            "lat": "-37.3159",
                            "lng": "81.1496"
                        }
                    },
                    "phone": "1-770-736-8031 x56442",
                    "website": "hildegard.org",
                    "company": {
                        "name": "Romaguera-Crona",
                        "catchPhrase": "Multi-layered client-server neural-net",
                        "bs": "harness real-time e-markets"
                    }
                }
            ]).encode("utf-8")))
        }

        # Call lambda_handler function
        result = lambda_handler(event, {})

        # Assertions
        mock_s3_client.get_object.assert_called_once_with(Bucket="test-bucket", Key="raw/users/users.json")
        mock_s3_client.put_object.assert_called_once_with(
            Bucket="test-bucket",
            Key="processed/users/processed_users.json",
            Body=json.dumps({
                "id": 1,
                "name": "Leanne Graham",
                "username": "Bret",
                "email": "Sincere@april.biz",
                "address_street": "Kulas Light",
                "address_suite": "Apt. 556",
                "address_city": "Gwenborough",
                "address_zipcode": "92998-3874",
                "address_geo_lat": "-37.3159",
                "address_geo_lng": "81.1496",
                "phone": "1-770-736-8031 x56442",
                "website": "hildegard.org",
                "company_name": "Romaguera-Crona",
                "company_catchPhrase": "Multi-layered client-server neural-net",
                "company_bs": "harness real-time e-markets"
            }) + "\n"
        )

        self.assertEqual(result["statusCode"], 200)
        self.assertEqual(result["body"], "Data processed, flattened, and saved in JSON Lines format")

    @patch('ProcessJsonPlaceholderUsers.boto3.client')
    def test_lambda_handler_s3_error(self, mock_boto3_client):
        # Configure mocks
        os.environ['S3_BUCKET'] = 'test-bucket'

        # Mock S3 event
        event = {
            "Records": [
                {
                    "s3": {
                        "bucket": {"name": "test-bucket"},
                        "object": {"key": "raw/users/users.json"}
                    }
                }
            ]
        }

        # Mock S3 error
        mock_s3_client = MagicMock()
        mock_boto3_client.return_value = mock_s3_client
        mock_s3_client.get_object.side_effect = Exception("S3 Error")

        # Call lambda_handler function
        result = lambda_handler(event, {})

        # Assertions
        self.assertEqual(result["statusCode"], 500)
        self.assertIn("Error reading file from S3", result["body"])

if __name__ == '__main__':
    unittest.main()