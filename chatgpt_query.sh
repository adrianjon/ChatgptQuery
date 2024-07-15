#!/bin/bash

# Script for chatgpt in terminal
# requires jq curl 

API_KEY=$(cat "$(dirname "$(realpath "$0")")/API_KEY")
MODEL="gpt-3,5-turbo"
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
HISTORY_FILE="$SCRIPT_DIR/chatgpt_query_history_$PPID.json"
PREFIX="You are an expert in command-line tools and scripting. Provide brief, concise, and to-the-point answers for command-line usage without any extra text. Give short examples on how to achieve the desired outcome."

if [ "$1" == "clear" ]; then
	echo "[]" > "$HISTORY_FILE"
	echo "History cleared"
	exit 0
fi

if [ "$#" -lt 1 ]; then
	echo "Usage: ? <chatgpt query> | clear"
	exit 1
fi

prompt="$*"

if [ ! -f "$HISTORY_FILE" ]; then
	echo "[]" > "$HISTORY_FILE"
fi

history=$(cat "$HISTORY_FILE")

new_history=$(jq --arg content "$prompt" '. + [{"role": "user", "content": $content}]' <<< "$history")

json_payload=$(jq -n --arg prefix "$PREFIX" --argjson history "$new_history" '{
	"model": "gpt-3.5-turbo",
	"messages": ( [{"role": "system", "content": $prefix}] + $history ),
	"max_tokens": 150
}')

echo "sending request..."

response=$(curl -s -X POST https://api.openai.com/v1/chat/completions \
	-H "Content-Type: application/json" \
	-H "Authorization: Bearer $API_KEY" \
	-d "$json_payload")

# Check if the response contains an error
if echo "$response" | jq -e .error > /dev/null; then
	echo "Error: $(echo "$response" | jq -r .error.message)"
	exit 1
fi

# Extract the text response
text=$(echo "$response" | jq -r '.choices[0].message.content')

if [ "$text" == "null" ]; then
	echo "Error: Received null response. Full response: $response"
	exit 1
fi

new_history=$(jq --arg content "$text" '. + [{"role": "assistant", "content": $content}]' <<< "$new_history")

echo "$new_history" > $HISTORY_FILE

echo "$text"

