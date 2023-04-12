import boto3

client_var = boto3.client('s3')

response_var = client_var.list_buckets()

#print(response_var['Buckets'])

for i in response_var['Buckets']:
    print (i['Name'])

