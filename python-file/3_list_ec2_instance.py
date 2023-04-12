import boto3

client = boto3.client('ec2')

response = client.describe_instances()

#print (response['Reservations'])

for Prntrevs in response ['Reservations']:
    for Prntinst in Prntrevs ['Instances']:
        print(Prntinst['InstanceId'])

