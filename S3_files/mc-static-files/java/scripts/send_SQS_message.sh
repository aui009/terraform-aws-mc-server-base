#!/bin/bash

get_player_count(){
    PLAYER_COUNT_MESSAGE_PATTERN=""
    
    echo "$(date +'%Y-%m-%d %H:%M:%S'): Getting player current player count"
    
}

message_data=$( cat <<- EOF
{
                    "detail-type": detail_type,
                    "source":      "com.tmplays.mc",
                    "time":        str(formatted_time),
                    "detail":  {
                                "server": "Survival",
                                "player_count": 0,
                                "server-ip": server_address,
                                "environment": env_var,
                                "server-message": server_message
                            }
                        }
EOF

)

echo "$(date +'%Y-%m-%d %H:%M:%S'): Sending message to SQS with data: $message_data"