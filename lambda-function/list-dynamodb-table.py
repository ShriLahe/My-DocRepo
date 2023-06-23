#that checks the existence of a DynamoDB table:
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
#=======================================================================
# that lists all DynamoDB tables in the AWS account:
import boto3

def lambda_handler(event, context):
    dynamodb = boto3.client('dynamodb')

    response = dynamodb.list_tables()

    if 'TableNames' in response:
        table_names = response['TableNames']
        print(f"Existing DynamoDB tables:")
        for table_name in table_names:
            print(table_name)
    else:
        print("No DynamoDB tables found.")
