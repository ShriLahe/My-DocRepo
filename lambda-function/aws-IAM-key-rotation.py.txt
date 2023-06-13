import boto3
import os
from datetime import datetime, timezone, timedelta
from botocore.exceptions import ClientError

#Creating a new Access Key
def create_new_key(iam, user_name):
    new_key = iam.create_access_key(UserName=user_name)['AccessKey']
    print(f"New access key is created for user {user_name}: {new_key['AccessKeyId']}")
    return new_key['AccessKeyId'], new_key['SecretAccessKey']

#Deactivating the old Access Key   
def deactivate_key(iam, user_name,  key_id):
    iam.update_access_key(UserName=user_name, AccessKeyId=key_id, Status='Inactive')
    print(f"Deactivated access key {key_id} for user {user_name}")
    
#Deleting the Old Access Key
def delete_key(iam, user_name, key_id):
    iam.delete_access_key(UserName=user_name, AccessKeyId=key_id)
    print(f"Deleted access key {key_id} for user {user_name}")
    
def lambda_handler(event, context):
    #Initializing the IAM client
    iam = boto3.client('iam')
    # Initializing SNS client
    sns = boto3.client('sns')
    topic_arn = os.environ['sns_topic_arn']
    try:
        #Getting a list of all IAM users
        response = iam.list_users()
    except ClientError as e:
        print(f"Failed to list IAM users: {e}")
        return{
            "statusCode":500,
            "body":"Failed to list IAM users"
        }
    
    #For each IAM user, check if any access keys are older than the specified time
    for user in response['Users']:
        user_name = user['UserName']
        try:
            access_keys = iam.list_access_keys(UserName=user_name)['AccessKeyMetadata']
        except ClientError as e:
            print(f"Failed to list access key for user {user_name}: {e}")
            continue
       
        for access_key in access_keys:
            key_id = access_key['AccessKeyId']
            status = access_key['Status']
            create_date = access_key['CreateDate']
            age = (datetime.now(timezone.utc)-create_date).days
            last_used = iam.get_access_key_last_used(AccessKeyId=key_id).get('AccessKeyLastUsed').get('LastUsedDate')
          
            try:
                if age == timedelta(days=int(os.environ['env1_create_key'])).days: 
                    new_key_id, new_secret = create_new_key(iam, user_name)
                    sns.publish(TopicArn=topic_arn,
                            Message=f"""A new access key has been created for user {user_name}:
                                    New Access Key Id= {new_key_id} 
                                    New Secret Key= {new_secret}
                    Please update the application and tool with a new access key. The old key will be inactive soon.""",
                            Subject="New Access Key Created")
                
                if age >= timedelta(days=int(os.environ['env2_disable_key'])).days and status =='Active':
                    if last_used is None:
                        deactivate_key(iam, user_name, key_id)
                        sns.publish(TopicArn=topic_arn,
                        Message=f"The access key {key_id} has been Inactivated for user {user_name}.",
                        Subject="Access Key Inactive")
                    elif((datetime.now(timezone.utc) - last_used).days >= int(os.environ['last_used_threshold'])):
                        deactivate_key(iam, user_name, key_id)
                        sns.publish(TopicArn=topic_arn,
                        Message=f"The access key {key_id} has been deactivated for user {user_name}.",
                        Subject="Access Key Inactive")
                    elif((datetime.now(timezone.utc) - last_used).days < int(os.environ['last_used_threshold'])):
                        sns.publish(TopicArn=topic_arn,
                        Message=f"""The access key {key_id} for user {user_name} is approaching expiration date and it will be deactivated soon.
                        Please start using new access key generated.""",
                        Subject="Inactive Access Key Alert")
                    
            
                if age >= timedelta(days=int(os.environ['env3_delete_key'])).days and status =='Inactive':
                    delete_key(iam, user_name, key_id)
                    sns.publish(TopicArn=topic_arn,
                            Message=f"The access key {key_id} has been deleted for user {user_name}.",
                            Subject="Access Key Deleted")
            except ClientError as e:
                print(f"Failed to rotate access key for user {user_name}: {e}")
                continue
            
            
    return {
        "statusCode": 200,
        "body": "Key Rotation is Successfully Completed!!"
    }