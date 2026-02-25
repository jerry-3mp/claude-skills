# Extract session summaries from Claude Code session JSONL
# Summaries are the highest-signal, lowest-noise way to find relevant sessions
# Usage: jq -r -f extract_summaries.jq session.jsonl

select(.type == "summary")
| .summary // .content // .text // .