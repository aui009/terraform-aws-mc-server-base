#!/bin/bash
screen -dmS minecraft bash -c "java -Xmx1G -Xms1G -jar server.jar nogui;exec bash"
