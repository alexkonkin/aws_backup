# aws_backup

Deploy stack to AWS:
aws cloudformation create-stack --stack-name ec2-mysql-server --template-body file://ec2.yaml --parameters file://ec2-params.json

Delete stack from AWS:
aws cloudformation delete-stack --stack-name ec2-mysql-server


