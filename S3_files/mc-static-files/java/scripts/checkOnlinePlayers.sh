#!/bin/bash

LOG_FILE="/opt/minecraft/server/logs/latest.log"
LAMBDA_FUNCTION="mc_sendSQStoMiku_handler_server_down"
TIME_INTERVAL=900

current_time=$(date +"%s")
echo "$(date +'%Y-%m-%d %H:%M:%S') Current time: $current_time"

player_online_count=$(grep "joined the game" $LOG_FILE | wc -l)
player_offline_count=$(grep "left the game" $LOG_FILE | wc -l)

echo "$(date +'%Y-%m-%d %H:%M:%S'): Players online: $player_online_count"
echo "$(date +'%Y-%m-%d %H:%M:%S'): Players offline: $player_offline_count"

current_online_players=$((player_online_count - player_offline_count))
echo "$(date +'%Y-%m-%d %H:%M:%S') Current online players: $current_online_players"

echo $(date -d "$(grep "left the game" $LOG_FILE | tail -n 1 | awk -F'[][]' '{print $2}')" +"%s")
if grep -q "left the game" $LOG_FILE; then
   echo "$(date +'%Y-%m-%d %H:%M:%S'): time extracted: $(date -d "$(grep "Server empty for 60 seconds" $LOG_FILE | tail -n 1 | awk -F'[][]' '{print $2}')" +"%T")"
   past_time=$(date -d "$(grep "left the game" $LOG_FILE | tail -n 1 | awk -F'[][]' '{print $2}')" +"%s")
   echo "$(date +'%Y-%m-%d %H:%M:%S'): Pattern left the game found. Past time: $past_time"
else
   #"Server empty for 60 seconds"
   echo "$(date +'%Y-%m-%d %H:%M:%S'): Pattern 'left the game' not found. Checking for 'Server empty for 60 seconds'"
   echo "$(date +'%Y-%m-%d %H:%M:%S'): time extracted: $(date -d "$(grep "Server empty for 60 seconds" $LOG_FILE | tail -n 1 | awk -F'[][]' '{print $2}')" +"%T")"
   past_time=$(date -d "$(grep "Server empty for 60 seconds" $LOG_FILE | tail -n 1 | awk -F'[][]' '{print $2}')" +"%s")

fi


diff_time=$(($current_time - $past_time))

echo "Time difference in seconds: $diff_time"

if [ "$diff_time" -ge $TIME_INTERVAL ] && [ "$current_online_players" -eq 0 ]; then
    echo "$(date +'%Y-%m-%d %H:%M:%S'): No players have been online for the past $((TIME_INTERVAL / 60)) minutes."
    aws lambda invoke --function-name $LAMBDA_FUNCTION --invocation-type Event --cli-binary-format raw-in-base64-out --payload '{"shutdown_cause": "no_online_players"}' output.json
    exit 0
else
    echo "$(date +'%Y-%m-%d %H:%M:%S'): Players have been online within the past $((TIME_INTERVAL / 60)) minutes."
fi