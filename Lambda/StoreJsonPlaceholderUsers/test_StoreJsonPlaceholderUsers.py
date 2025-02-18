import unittest
from unittest.mock import patch, MagicMock
import os
import json
from datetime import datetime
from StoreJsonPlaceholderUsers import lambda_handler # Assurez-vous que le nom du fichier est correct

class TestLambdaHandler(unittest.TestCase):

    @patch('StoreJsonPlaceholderUsers.requests.get')  # Mock pour requests.get
    @patch('StoreJsonPlaceholderUsers.boto3.client')  # Mock pour boto3.client
    def test_lambda_handler_success(self, mock_boto3_client, mock_requests_get):
        # Mock de la variable d'environnement
        os.environ['S3_BUCKET'] = 'test-bucket'

        # Mock de la réponse de l'API
        mock_response = MagicMock()
        mock_response.status_code = 200
        mock_response.json.return_value = [{"id": 1, "name": "John Doe"}]
        mock_requests_get.return_value = mock_response

        # Mock du client S3
        mock_s3_client = MagicMock()
        mock_boto3_client.return_value = mock_s3_client

        # Appel de la fonction lambda_handler
        event = {}
        context = {}
        result = lambda_handler(event, context)

        # Vérifications
        mock_requests_get.assert_called_once_with("https://jsonplaceholder.typicode.com/users")
        mock_boto3_client.assert_called_once_with('s3')

        # Vérification du nom du fichier
        date_today = datetime.now().strftime("%Y-%m-%d")
        expected_file_name = f"raw/users/jsonplaceholder_users_{date_today}.json"
        mock_s3_client.put_object.assert_called_once_with(
            Bucket='test-bucket',
            Key=expected_file_name,
            Body=json.dumps([{"id": 1, "name": "John Doe"}])
        )

        # Vérification du résultat
        self.assertEqual(result['statusCode'], 200)
        self.assertEqual(json.loads(result['body']), 'Data successfully stored in S3')

    @patch('StoreJsonPlaceholderUsers.requests.get')  # Mock pour requests.get
    def test_lambda_handler_api_failure(self, mock_requests_get):
        # Mock de la variable d'environnement
        os.environ['S3_BUCKET'] = 'test-bucket'

        # Mock de la réponse de l'API pour simuler un échec
        mock_response = MagicMock()
        mock_response.status_code = 400
        mock_requests_get.return_value = mock_response

        # Appel de la fonction lambda_handler
        event = {}
        context = {}
        result = lambda_handler(event, context)

        # Vérifications
        mock_requests_get.assert_called_once_with("https://jsonplaceholder.typicode.com/users")

        # Vérification du résultat
        self.assertEqual(result['statusCode'], 400)
        self.assertEqual(json.loads(result['body']), 'Error calling the JSONPlaceholder API')

if __name__ == '__main__':
    unittest.main()