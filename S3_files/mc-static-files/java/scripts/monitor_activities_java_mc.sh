#!/bin/bash

LOG_FILE="/opt/minecraft/server/logs/latest.log"
FILE_DEATH_KEYWORD_LIST="/opt/minecraft/files/MC_java_death_keywords_list.txt"

PATTERN_JOINED="joined the game"
PATTERN_LEFT="left the game"


mapfile -t KEYWORD_DEATH_LIST < "$FILE_DEATH_KEYWORD_LIST"

KEYWORD_DEATH_LIST=("${KEYWORD_DEATH_LIST[@]//\"/}")

PLAYER_MESSAGE_PATTERN="<[^>]+>"

LAMBDA_FUNCTION="mc_sendSQSPlayerEvent_handler"

echo "$(date +'%Y-%m-%d %H:%M:%S'): Start Monitoring $LOG_FILE"
echo "${KEYWORD_DEATH_LIST[@]}"
tail -fn0 "$LOG_FILE" | while read -r LINE
do
        echo "reading line: $LINE"
        if echo "$LINE" | grep -q "$PATTERN_JOINED" && ! echo "$LINE" | grep -qE "$PLAYER_MESSAGE_PATTERN";then
           player_name=$(echo "$LINE" | awk '{print $4}')
           echo "$(date +'%Y-%m-%d %H:%M:%S'): player $player_name has joined"
           screen -S minecraft -X stuff 'say §aWelcome '"$player_name"' to the Server!\n'
           detail_type="Player Joined Minecraft Server"
           server_message="Player $player_name has joined the server"
           aws lambda invoke --function-name $LAMBDA_FUNCTION --cli-binary-format raw-in-base64-out --payload '{"detail_type": "'"$detail_type"'", "server_message": "'"$server_message"'"}' output.json
        elif echo "$LINE" | grep -q "$PATTERN_LEFT" && ! echo "$LINE" | grep -qE "$PLAYER_MESSAGE_PATTERN";then
           player_name=$(echo "$LINE" | awk '{print $4}')
           echo "$(date +'%Y-%m-%d %H:%M:%S'): player $player_name has left"
           screen -S minecraft -X stuff 'say §9Goodbye '"$player_name"', hope to see you soon!\n'
           detail_type="Player Left Minecraft Server"
           server_message="Player $player_name has left the server"
           aws lambda invoke --function-name $LAMBDA_FUNCTION --cli-binary-format raw-in-base64-out --payload '{"detail_type": "'"$detail_type"'", "server_message": "'"$server_message"'"}' output.json

        elif grep -iqFf  <(printf "%s\n" "${KEYWORD_DEATH_LIST[@]}") <<< "$LINE" && ! echo "$LINE" | grep -qE "$PLAYER_MESSAGE_PATTERN";then
           echo "$(date +'%Y-%m-%d %H:%M:%S'): A Player has died"
           DEATH_MESSAGE=$(echo "$LINE" | awk -F': ' '{print $2}')
           echo "$(date +'%Y-%m-%d %H:%M:%S'): $DEATH_MESSAGE"
           detail_type="Player Died in Minecraft Server"
           server_message=$DEATH_MESSAGE
           aws lambda invoke --function-name $LAMBDA_FUNCTION --cli-binary-format raw-in-base64-out --payload '{"detail_type": "'"$detail_type"'", "server_message": "'"$server_message"'"}' output.json
        fi
done