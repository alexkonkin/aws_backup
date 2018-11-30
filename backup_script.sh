#!/bin/bash
#parameters
stack_name="ec2-mysql-server"
bucket_name="alekomail-backup"

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












