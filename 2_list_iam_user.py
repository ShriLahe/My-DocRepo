import boto3

client_var = boto3.client('iam')

response_var = client_var.list_users()

#print (response_var ['Users'])

for abc in response_var['Users']:
    print (abc['UserName'], abc['CreateDate'])