# Extract a specific message by UUID from Claude Code session JSONL
# Usage: jq -r --arg uuid "UUID_HERE" -f extract_by_uuid.jq session.jsonl
#
# Pass UUID via: jq --arg uuid "abc123" -r -f extract_by_uuid.jq file.jsonl

def get_content:
  if type == "string" then .
  elif type == "array" then
    [.[] | select(type == "object" and .type == "text") | .text] | join(" ")
  else "" end;

select(.uuid == $uuid or .parentUuid == $uuid)
| {
    uuid: .uuid,
    type: .type,
    timestamp: .timestamp,
    content: (.message.content | get_content)[0:1000]
  }