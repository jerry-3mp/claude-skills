---
name: pensieve
description: Search past Claude Code sessions in ~/.claude/projects for previous conversations, decisions, and solutions. Use when needing to find earlier work on a topic, recall past decisions, or reference previous implementations.
---

# Pensieve - Low-Output Session History Search

Search through Claude Code session history efficiently while **minimizing context consumption**.

## DANGER: What Will Waste 80k-100k Tokens

**NEVER do these things:**

```bash
# WRONG - greps raw JSONL, matches tool_result with full file dumps
rg -n 'search_term' "$SESSION" | head -20

# WRONG - outputs raw JSONL lines
jq '.' "$SESSION" | head -100

# WRONG - reads entire file
cat "$SESSION"
```

**WHY**: JSONL contains `tool_result` entries with **full file contents** from Read operations. Grepping raw JSONL will match these and dump thousands of lines of code.

**ALWAYS do this instead:**

```bash
# RIGHT - filter through jq scripts FIRST, then grep the clean output
jq -r -f ~/.claude/skills/pensieve/scripts/extract_user_text.jq "$SESSION" | rg 'search_term'
jq -r -f ~/.claude/skills/pensieve/scripts/extract_transcript.jq "$SESSION" | rg 'search_term'
```

## CRITICAL: Output Caps (MUST FOLLOW)

| Phase | Cap | Default |
|-------|-----|---------|
| File candidates | Top N files | N=10 |
| User inputs | Last W messages | W=25 |
| Transcript | Last L lines | L=120 |
| Match hits | Max M per file | M=3 |

## Two-Phase Workflow

### Phase A: Narrow to Candidate Files (LOW OUTPUT)

**Goal**: Find the right session file(s) using **filenames and counts only**.

```bash
ROOT=~/.claude/projects/<YOUR-PROJECT-DIR>

# 1. Rank files by match count (TOP 10 ONLY)
rg -c --glob '*.jsonl' 'SEARCH_TERM' "$ROOT" | sort -t: -k2,2nr | head -10

# 2. Check timestamps of top files
for f in FILE1 FILE2 FILE3; do
  echo "=== $(basename $f) ==="
  jq -r 'select(.type=="user") | .timestamp' "$f" 2>/dev/null | head -1
done
```

**After narrowing**: Use `AskUserQuestion` to confirm which file before extracting.

### Phase B: Extract Content (CAPPED OUTPUT)

**Goal**: Read user inputs and key content from confirmed file(s).

```bash
SESSION=/path/to/CHOSEN.jsonl

# 1. Last 25 user inputs (high-signal, low noise)
jq -r -f ~/.claude/skills/pensieve/scripts/extract_user_text.jq "$SESSION" | tail -25

# 2. Search within filtered output (SAFE)
jq -r -f ~/.claude/skills/pensieve/scripts/extract_user_text.jq "$SESSION" | rg -i 'keyword' | head -10

# 3. Clean transcript (user + assistant text only)
jq -r -f ~/.claude/skills/pensieve/scripts/extract_transcript.jq "$SESSION" | tail -120

# 4. Summaries only (fastest)
jq -r -f ~/.claude/skills/pensieve/scripts/extract_summaries.jq "$SESSION"
```

## UUID-Based Lookups

Each message has a `uuid` field. Use this for precise extraction:

```bash
SESSION=/path/to/session.jsonl

# 1. Find UUIDs of user messages mentioning a term
jq -r 'select(.type=="user") | select(.message.content | type=="string") |
  select(.message.content | test("keyword"; "i")) |
  "\(.uuid)\t\(.timestamp)\t\(.message.content[0:100])"' "$SESSION" | head -10

# 2. Extract specific message by UUID (includes parent/child)
jq -r --arg uuid "TARGET_UUID" -f ~/.claude/skills/pensieve/scripts/extract_by_uuid.jq "$SESSION"

# 3. Get conversation thread around a UUID
jq -r --arg uuid "TARGET_UUID" 'select(.uuid==$uuid or .parentUuid==$uuid)' "$SESSION" | \
  jq -r -f ~/.claude/skills/pensieve/scripts/extract_transcript.jq
```

## Session File Structure

Sessions stored in `~/.claude/projects/` as **JSONL files**:

- **Directory naming**: Path with slashes to hyphens
  - `/Users/<username>/Projects/my-app` → `-Users-<username>-Projects-my-app/`

- **Key fields per line**:
  - `uuid` - Unique ID for this message
  - `parentUuid` - Parent message UUID (for threading)
  - `type` - "user", "assistant", or "summary"
  - `timestamp` - ISO timestamp
  - `message.content` - String (user) or Array (assistant with tool_use)
  - `sessionId` - Session UUID for `/resume`
  - `gitBranch` - Git branch during session

## Interactive Narrowing with AskUserQuestion

Use `AskUserQuestion` to reduce scope when:
- Many matching session files exist
- Search term is too broad
- User wants specific portion of conversation

**Template questions**:

1. **Pick session**: "I found N matching sessions. Which looks right? (1-10 or paste filename)"
2. **Pick time window**: "Roughly when was this? Today / Yesterday / Last week / Older"
3. **Pick conversation portion**: "Within this session: Beginning / Middle / End / Around phrase?"

## Recipes

### Recipe 1: Quick File Discovery + User Preview
```bash
ROOT=~/.claude/projects/<YOUR-PROJECT-DIR>

# Rank by match count, show top 5 with user input preview
rg -c --glob '*.jsonl' 'SEARCH_TERM' "$ROOT" | sort -t: -k2,2nr | head -5 | cut -d: -f1 | \
  while IFS= read -r f; do
    echo "=== $(basename $f) ==="
    jq -r -f ~/.claude/skills/pensieve/scripts/extract_user_text.jq "$f" | rg -i 'SEARCH_TERM' | head -3
  done
```

### Recipe 2: Find Discussion by Date
```bash
ROOT=~/.claude/projects/<YOUR-PROJECT-DIR>

# Find sessions from specific date (e.g., 2025-12-23)
for f in "$ROOT"/*.jsonl; do
  ts=$(jq -r 'select(.type=="user") | .timestamp' "$f" 2>/dev/null | head -1)
  [[ "$ts" == 2025-12-23* ]] && echo "$f: $ts"
done
```

### Recipe 3: Search Within a Session (SAFE)
```bash
SESSION=/path/to/session.jsonl

# ALWAYS filter first, THEN grep - never grep raw JSONL
jq -r -f ~/.claude/skills/pensieve/scripts/extract_user_text.jq "$SESSION" | rg -i 'keyword'
jq -r -f ~/.claude/skills/pensieve/scripts/extract_transcript.jq "$SESSION" | rg -i 'keyword' | head -20
```

### Recipe 4: Get Context Around a Keyword Match
```bash
SESSION=/path/to/session.jsonl

# Find which user messages mention the keyword
jq -r 'select(.type=="user") | select(.message.content | type=="string") |
  select(.message.content | test("keyword"; "i")) |
  "\(.uuid)\t\(.timestamp)"' "$SESSION" | head -5

# Then get transcript around that timestamp (filter first!)
jq -r -f ~/.claude/skills/pensieve/scripts/extract_transcript.jq "$SESSION" | \
  rg -B5 -A10 'keyword' | head -40
```

### Recipe 5: Summaries First (Fastest Discovery)
```bash
ROOT=~/.claude/projects/<YOUR-PROJECT-DIR>

for f in "$ROOT"/*.jsonl; do
  summary=$(jq -r 'select(.type=="summary") | .summary' "$f" 2>/dev/null | head -1)
  [[ -n "$summary" ]] && echo "$(basename $f): $summary"
done | rg -i 'SEARCH_TERM' | head -10
```

## Helper Scripts

```
~/.claude/skills/pensieve/scripts/
  extract_user_text.jq     # User inputs only (strings, not tool_result)
  extract_transcript.jq    # User + assistant text (500 char cap, skips tool_use)
  extract_summaries.jq     # Session summaries only
  extract_by_uuid.jq       # Extract specific message by UUID
```

## Output Format

Results MUST be **self-sufficient** - usable directly without resuming source session.

```
[Session: {uuid} | {timestamp} | Branch: {branch}]

**Context**: {what was being worked on}

**Finding**: {key information, decision, or solution}

**Details**:
- {specific files with paths}
- {commands or code snippets}

**Action**: {what can be done with this info, or `/resume {uuid}` for full discussion}
```

## Temporal Awareness

Session data is **point-in-time knowledge** that may be outdated:
- Code may have been moved, renamed, refactored, or deleted
- Later sessions may have changed the approach
- Always verify against current codebase state

## Tips

- **NEVER grep raw JSONL** - always pipe through jq scripts first
- **Search summaries first** - highest signal, lowest noise
- **User inputs before transcripts** - what user asked reveals context
- **Use UUID for precision** - find exact message, then get context
- **Verify with current code** - cross-reference with `git log` and current files
- **Use `/resume {sessionId}`** - to continue a previous session conversation