#!/bin/bash

#AMI_ID="ami-09c813fb71547fc4f"
#SG_ID="sg-01bc7ebe005fb1cb2" # replace with your SG ID
#INSTANCES=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "dispatch" "frontend")
#ZONE_ID="Z032558618100M4EJX8X4" # replace with your ZONE ID
#DOMAIN_NAME="daws84s.site" # replace with your domain

#for instance in ${INSTANCES[@]}
#for instance in $@
#do
    #INSTANCE_ID=$(aws ec2 run-instances --image-id ami-09c813fb71547fc4f --instance-type t3.micro --security-group-ids sg-01bc7ebe005fb1cb2 --tag-specifications "ResourceType=instance,Tags=[{Key=Name, Value=$instance}]" --query "Instances[0].InstanceId" --output text)
    #if [ $instance != "frontend" ]
    #then
        #IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].PrivateIpAddress" --output text)
        #RECORD_NAME="$instance.$DOMAIN_NAME"
    #else
       # IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].PublicIpAddress" --output text)
        #RECORD_NAME="$DOMAIN_NAME"
    #fi
    #echo "$instance IP address: $IP"

    #aws route53 change-resource-record-sets \
    #--hosted-zone-id $ZONE_ID \
    #--change-batch '
    #{
       # "Comment": "Creating or Updating a record set for cognito endpoint"
     #   ,"Changes": [{
       # "Action"              : "UPSERT"
        #,"ResourceRecordSet"  : {
         #   "Name"              : "'$RECORD_NAME'"
          #  ,"Type"             : "A"
           # ,"TTL"              : 1
            #,"ResourceRecords"  : [{
               # "Value"         : "'$IP'"
            #}]
       # }
        #}]
    #}'
#done


AMI_ID="ami-0220d79f3f480ecf5"
SG_ID="sg-02681d66fcc9bc385"
INSTANCE_TYPE="t3.micro"

for instance in "$@"
do
    echo "Launching instance: $instance"

    INSTANCE_ID=$(aws ec2 run-instances \
        --image-id "$AMI_ID" \
        --instance-type "$INSTANCE_TYPE" \
        --security-group-ids "$SG_ID" \
        --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
        --query "Instances[0].InstanceId" \
        --output text)

    echo "Instance ID: $INSTANCE_ID"

    # Wait until instance is running
    aws ec2 wait instance-running --instance-ids "$INSTANCE_ID"

    if [ "$instance" != "frontend" ]; then
        IP=$(aws ec2 describe-instances \
            --instance-ids "$INSTANCE_ID" \
            --query "Reservations[0].Instances[0].PrivateIpAddress" \
            --output text)
        echo "$instance Private IP: $IP"
    else
        IP=$(aws ec2 describe-instances \
            --instance-ids "$INSTANCE_ID" \
            --query "Reservations[0].Instances[0].PublicIpAddress" \
            --output text)
        echo "$instance Public IP: $IP"
    fi

    echo "-------------------------------------"
done
