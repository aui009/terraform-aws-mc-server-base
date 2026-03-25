#!/bin/bash

LOG_FILE="/opt/minecraft/server/logs/latest.log"
FILE_DEATH_KEYWORD_LIST="/opt/minecraft/files/MC_java_death_keywords_list.txt"

PATTERN_JOINED="joined the game"
PATTERN_LEFT="left the game"


mapfile -t KEYWORD_DEATH_LIST < "$FILE_DEATH_KEYWORD_LIST"

KEYWORD_DEATH_LIST=("${KEYWORD_DEATH_LIST[@]//\"/}")

PLAYER_MESSAGE_PATTERN="<[^>]+>"

echo "$(date +'%Y-%m-%d %H:%M:%S'): Start Monitoring $LOG_FILE"
echo "${KEYWORD_DEATH_LIST[@]}"
tail -fn0 "$LOG_FILE" | while read -r LINE
do
        echo "reading line: $LINE"
        if echo "$LINE" | grep -q "$PATTERN_JOINED" && ! echo "$LINE" | grep -qE "$PLAYER_MESSAGE_PATTERN";then
           player_name=$(echo "$LINE" | awk '{print $4}')
           echo "$(date +'%Y-%m-%d %H:%M:%S'): player $player_name has joined"
           screen -S minecraft -X stuff 'say §aWelcome '"$player_name"' to the Server!\n'

        elif echo "$LINE" | grep -q "$PATTERN_LEFT" && ! echo "$LINE" | grep -qE "$PLAYER_MESSAGE_PATTERN";then
           player_name=$(echo "$LINE" | awk '{print $4}')
           echo "$(date +'%Y-%m-%d %H:%M:%S'): player $player_name has left"
           screen -S minecraft -X stuff 'say §9Goodbye '"$player_name"', hope to see you soon!\n'

        elif grep -iqFf  <(printf "%s\n" "${KEYWORD_DEATH_LIST[@]}") <<< "$LINE" && ! echo "$LINE" | grep -qE "$PLAYER_MESSAGE_PATTERN";then
           echo "$(date +'%Y-%m-%d %H:%M:%S'): A Player has died"
           DEATH_MESSAGE=$(echo "$LINE" | awk -F': ' '{print $2}')
           echo "$(date +'%Y-%m-%d %H:%M:%S'): $DEATH_MESSAGE"
        fi
done