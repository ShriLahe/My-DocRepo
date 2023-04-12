import boto3

client = boto3.client('ec2')
response = client.describe_vpcs()

#print(response['Vpcs'])

for vpcinfo in response['Vpcs']:
    print (vpcinfo['VpcId'], vpcinfo['CidrBlock'])