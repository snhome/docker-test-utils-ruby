#!/bin/bash

function sendMessage(){
    chat_id=$1
    text="$2"
    [ -z "$chat_id" ] && echo "no action" && exit 1
    [ -z "$text" ] && echo "no action" && exit 1
    echo "{\"chat_id\": \"${chat_id}\", \"text\": \"${text}\", \"disable_notification\": true}"
    curl -X POST \
        -H 'Content-Type: application/json' \
        -d "{\"chat_id\": \"${chat_id}\", \"text\": \"${text}\", \"disable_notification\": true}" \
        https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage
}
if [ -z ${TELEGRAM_BOT_TOKEN+x} ]; then echo "set TELEGRAM_BOT_TOKEN first" && exit 1; fi

action=$1
shift
[ -z "$action" ] && echo "no action" && exit 1
$action "$@"