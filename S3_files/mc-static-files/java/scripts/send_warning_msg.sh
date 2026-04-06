#!/bin/bash

set -e

LAMBDA_FUNCTION="mc_sendSQSPlayerEvent_handler"
detail_type="Server Shutdown Warning"
server_message="Warning: Server will be shutting down in 1 hour..."
echo "$(date +'%Y-%m-%d %H:%M:%S'): Sending Warning Message to Server and Discord Channel..."
screen -S minecraft -X stuff 'say §eWarning: Server will be shutting down in 1 hour...\n'
aws lambda invoke --function-name $LAMBDA_FUNCTION --cli-binary-format raw-in-base64-out --payload '{"detail_type": "'"$detail_type"'", "server_message": "'"$server_message"'"}' output_warning_msg.json
echo "$(date +'%Y-%m-%d %H:%M:%S'): Message sent successfully!"