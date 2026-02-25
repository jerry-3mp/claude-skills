# Extract clean transcript (user + assistant text only) from Claude Code session JSONL
# Skips tool_use, tool_result blocks - only outputs human-readable text
# Usage: jq -r -f extract_transcript.jq session.jsonl | tail -120

# Handle content that can be string or array
def get_content:
  if type == "string" then .
  elif type == "array" then
    [.[] | select(type == "object" and .type == "text") | .text] | join(" ")
  else "" end;

select(.type == "user" or .type == "assistant")
| select(.message.content != null)
| (.message.content | get_content) as $text
| select($text | length > 0)
| .timestamp + "\t" + (.type | ascii_upcase) + "\t" + $text[0:500]