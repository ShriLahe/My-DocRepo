import boto3

def lambda_handler(event, context):
    # Provide the name of your DynamoDB table
    table_name = 'YourDynamoDBTableName'

    dynamodb = boto3.client('dynamodb')

    try:
        # Check if the table exists
        response = dynamodb.describe_table(TableName=table_name)
        print(f"DynamoDB table '{table_name}' exists!")
        print(f"Table details: {response}")
    except dynamodb.exceptions.ResourceNotFoundException:
        print(f"DynamoDB table '{table_name}' does not exist!")
