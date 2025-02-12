import json
import boto3

kinesis_client = boto3.client('kinesis')

def lambda_handler(event, context):
    # API Gateway transmet les données au format JSON
    data = json.loads(event['body'])  # Récupère les données envoyées par RandomUser API

    # Nom du stream Kinesis
    stream_name = 'GETrandomUserAPI'

    # Envoi des données à Kinesis   
    response = kinesis_client.put_record(
        StreamName=stream_name,
        Data=json.dumps(data),
        PartitionKey="random_user_key"
    )

    print(f"Data sent to Kinesis: {response}")
    return {
        'statusCode': 200,
        'body': json.dumps('Data sent to Kinesis')
    }
