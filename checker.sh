#!/bin/bash

# Set your AWS region
AWS_REGION="us-west-2"  # Change this to your desired region

# Function to check if a role is attached to any instance
check_role() {
    local role_name=$1
    local instances=$(aws ec2 describe-instances --region $AWS_REGION --filters "Name=iam-instance-profile.arn,Values=*$role_name" --query 'Reservations[*].Instances[*].[InstanceId,Tags[?Key==`Name`].Value|[0]]' --output text)
    
    if [ -z "$instances" ]; then
        echo "Role '$role_name' is not attached to any EC2 instance."
    else
        echo "Role '$role_name' is attached to the following instance(s):"
        echo "Instance ID | Instance Name"
        echo "-----------|---------------"
        echo "$instances" | while read -r instance_id instance_name; do
            if [ -z "$instance_name" ]; then
                instance_name="<No Name>"
            fi
            printf "%-11s | %s\n" "$instance_id" "$instance_name"
        done
    fi
}

# List all IAM roles
echo "Listing all IAM roles:"
aws iam list-roles --query 'Roles[*].RoleName' --output table

# Check the specific roles
echo -e "\nChecking specific roles:"
check_role "dynamodb-read-write-ec2-role"
check_role "AmazonSSMRoleForInstancesQuickSetup"

echo -e "\nScript execution completed."
