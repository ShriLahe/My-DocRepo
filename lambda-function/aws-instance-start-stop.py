import boto3
import json


def lambda_handler(event, context):
    clint = boto.clint("ec2")

    isinstance = []

    myec2 = clint.describe_instances()
    for printins in myec2["Reservatons"]:
        for printout in printins["Instances"]:
            print(printout["InstanceID"], printout["InstanceType"], printout["LaunchTime"], printout["State"]["Name"])

            instance.append(printout[InstanceID])

    clint.stop_instances(InstanceIds=instances)
    print("Instances are stopped")
    
