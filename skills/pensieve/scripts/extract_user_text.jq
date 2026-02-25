# Extract user inputs from Claude Code session JSONL
# Filters out tool_result messages - only shows actual user text input
# Usage: jq -r -f extract_user_text.jq session.jsonl | tail -25

select(.type == "user")
| select(.message.content | type == "string")
| select(.message.content | length > 0)
| .timestamp + "\t" + .message.content