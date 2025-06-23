#!/bin/bash
INSTANCE_ID="<instance-id>"
aws ec2 start-instances --instance-ids $INSTANCE_ID --region us-east-1
