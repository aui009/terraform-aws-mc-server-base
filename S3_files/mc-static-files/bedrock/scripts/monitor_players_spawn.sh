#!/bin/bash

LOG_FILE="/opt/minecraft/logs/minecraft_screen_logs.log"

KEYWORD_SPAWN="Player Spawned: "

KEYWORD_DISCONNECT="Player disconnected:"

ACCOUNT_ID=$(sudo aws sts get-caller-identity --query 'Account' --output text)

ENV=$(sudo aws ssm get-parameter --name "MC-environment" --with-decryption --query Parameter.Value --output text)

QUEUE_URL="https://sqs.ap-southeast-1.amazonaws.com/$ACCOUNT_ID/miku-test-queue"

INSTANCE_IP=$(curl checkip.amazonaws.com)

echo "$(date +'%Y-%m-%d %H:%M:%S'): Start Monitoring $LOG_FILE"
player_count=0
tail -fn0 "$LOG_FILE" | while read -r LINE
do
   if echo "$LINE" | grep -q "$KEYWORD_SPAWN"; then
          player_name=$(echo "$LINE" | awk '{print $6}')
          player_count=$((player_count + 1))
          echo "$(date +'%Y-%m-%d %H:%M:%S'): Player $player_name has joined"
          echo "$(date +'%Y-%m-%d %H:%M:%S'): Player count is $player_count"
          screen -S minecraft -X stuff 'say §aWelcome '"$player_name"' to the Server!\n'
          echo "$(date +'%Y-%m-%d %H:%M:%S'): Sending SQS notification..."

          sudo aws sqs send-message --queue-url $QUEUE_URL --message-body "{\"detail-type\":\"Player Spawned in Server\",\"source\":\"com.tmplays.mc\",\"time\":\"2026-03-19T10:00:00Z\",\"detail\":{\"server\":\"Survival\",\"player_count\":1,\"server-ip\":\"$INSTANCE_IP\",\"environment\": \"$ENV\",\"server-message\":\"Player ${player_name} has spawned in minecraft server\"}}"
    elif echo "$LINE" | grep -q "$KEYWORD_DISCONNECT"; then
          player_name=$(echo "$LINE" | awk '{print $6}' | tr -d ',')
          player_count=$((player_count - 1))         
          echo "$(date +'%Y-%m-%d %H:%M:%S'): Player $player_name has left the server"
          echo "$(date +'%Y-%m-%d %H:%M:%S'): Player count is $player_count"
          screen -S minecraft -X stuff 'say §9Goodbye '"$player_name"', hope to see you soon!\n'
          echo "$(date +'%Y-%m-%d %H:%M:%S'): Sending SQS notification..."
         
         sudo aws sqs send-message --queue-url $QUEUE_URL --message-body "{\"detail-type\":\"A Player Disconnected from the Server\",\"source\":\"com.tmplays.mc\",\"time\":\"2026-03-19T10:00:00Z\",\"detail\":{\"server\":\"Survival\",\"player_count\":1,\"server-ip\":\"$INSTANCE_IP\",\"environment\": \"$ENV\",\"server-message\":\"Player ${player_name} has disconnected in minecraft server\"}}"
    fi  
done