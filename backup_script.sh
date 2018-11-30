#!/bin/bash
#parameters
stack_name="ec2-mysql-server"
server_name="MySqlServer"
bucket_name="alekomail-backup"
key_name="./MyEc2KeyPair.pem"
server_ip=""
server_backup_path="/opt/mysql_backup/*"
local_backup_path="./store"

#some initial tests that should assure that
#aws cli is available and can connect to the cloud

which aws > /dev/null 2>&1
if [ $? != 0 ]
then
    echo "Error: aws binary is not available"
    exit 1
fi

aws --version > /dev/null 2>&1
if [ $? != 0 ]
then
    echo "Error: can not execute aws command"
    exit 1
fi

aws ec2 describe-regions --output table > /dev/null 2>&1
if [ $? -eq 255 ]
then
    echo "Error: please configure your region, login and password information"
    echo "by executing   aws configure   command"
    exit 1
fi

result=$(aws cloudformation describe-stacks --stack-name $stack_name --query "Stacks[*].StackStatus" --output text 2>&1)
if [ $? != 0 ]
then
    echo "Error:"
    echo $result
    exit 1
  else
    output=$(aws cloudformation describe-stacks --stack-name $stack_name --query "Stacks[*].StackStatus" --output text 2>&1)
    if [ $output != "CREATE_COMPLETE" ]
    then
      echo "Error:"
      echo "Stack status is: $output"
      exit 1
    else
      echo "Stack with name $stack_name has been found and active"
    fi
fi

output=$(aws s3api list-buckets --query 'Buckets[?Name == `'$bucket_name'`].Name' --output text)
if [ `echo $output|wc -c` == 0 ]
then
    echo "Error:"
    echo "Bucket with name $bucket_name has not found"
    exit 1
  else
    echo "Bucket $bucket_name has been found"
fi

if [ -z $key_name ]
then
    echo "Error:"
    echo "Key file has not been found $key_name"
fi

server_ip=$(aws ec2 describe-instances --filter Name="tag:Name,Values=$server_name" --query "Reservations[*].Instances[*][Tags[?Key=='Name'].Value[],NetworkInterfaces[0].PrivateIpAddresses[0].Association.PublicIp]" --output text | xargs | awk -F ' ' '{print $1}')
if [ `echo $output|wc -c` == 0 ]
then
    echo "Error:"
    echo "Public if of the server with name $server_name has not found"
    exit 1
  else
    echo "Ip of the server $server_name is $server_ip"
fi

if [ -z $local_backup_path ]
then
    mkdir $local_backup_path
fi

echo "Copy of the files from $server_ip to the $local_backup_path is starting"
rsync -avz -e "ssh -i $key_name -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" --progress ec2-user@$server_ip:$server_backup_path $local_backup_path

echo "Copy of the backup files from $local_backup_path is starting"
aws s3 sync --delete $local_backup_path s3://$bucket_name/ --delete








