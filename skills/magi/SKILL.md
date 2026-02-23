---
name: magi
description: Run the same prompt through 3 parallel agent instances to compare results and find consensus. Named after Evangelion's 3-computer MAGI system. Use for design decisions, implementation questions, statistical tasks, factual research, or any decision where consensus matters.
disable-model-invocation: true
argument-hint: [task-description]
---

# MAGI - Parallel Agent Consensus System

Named after Evangelion's MAGI supercomputer system (Melchior, Balthasar, Casper), this skill runs your prompt through 3 parallel agent instances and compares their results to identify consensus, divergence, and outliers.

## Critical Constraint: READ-ONLY ANALYSIS SYSTEM

**MAGI is purely analytical. Agents analyze and propose - they do NOT implement.**

**Agents MUST NOT:**
- Edit, create, or delete any project files
- Make git commits or changes
- Run build/deploy/migration commands

**Agents MAY:**
- Read files and documentation
- Search and analyze codebase
- Return text-based analysis and proposals
- Suggest code changes (as text recommendations, not edits)

## How It Works

MAGI sends your exact prompt to three agents running in parallel:

**Consensus Mode** (for design/implementation/architecture decisions):
- **CASPER** (Implementation-Focused): Emphasizes practical feasibility, quick wins, pragmatic solutions
- **BALTHASAR** (Architecture-Focused): Prioritizes scalability, maintainability, long-term design
- **MELCHIOR** (Robustness-Focused): Focuses on edge cases, failure modes, security, resilience

**Identical Mode** (for math, statistics, calculations, factual research):
- All 3 agents run with identical prompts and NO different focuses
- Purpose: Reduce noise, find consensus, catch LLM errors in technical domains

## Task Type Detection

Automatically detect which mode to use:
- "Is this asking for design/architecture advice?" → **Consensus mode** (apply focuses)
- "Is this asking for calculation/verification/facts?" → **Identical mode** (no focuses)

**If the task type is ambiguous or unclear**, you MUST use the AskUserQuestion tool to ask the user before proceeding:

- **Header:** "MAGI Mode"
- **Question:** "Which mode should MAGI use for this task?"
- **Options:**
  1. **Consensus Mode** - For design, architecture, implementation decisions (uses CASPER/BALTHASAR/MELCHIOR focuses)
  2. **Identical Mode** - For math, statistics, calculations, factual verification (3 identical agents, no focuses)

Wait for the user's response, then proceed with the selected mode.

---

## Your Task

**TASK:** $ARGUMENTS

---

## Execution Instructions

### Step 1: Detect Task Type

Analyze the task above and determine:
- If it clearly involves design, implementation, architecture, or tradeoffs → Use **Consensus Mode**
- If it clearly involves math, statistics, calculations, or factual verification → Use **Identical Mode**
- **If uncertain or ambiguous** → Use AskUserQuestion tool to ask the user which mode to use. Do NOT assume or default.

### Step 2: Run Three Agents in Parallel

Use the Task tool to launch 3 agents with `subagent_type: general-purpose`. Run them in parallel (single message with 3 Task tool calls).

---

#### File System Isolation (CRITICAL)

Subagents share the same `/tmp` directory. To prevent race conditions and file pollution between parallel agents, each agent MUST use its own isolated temp directory.

**Before launching agents**, generate a unique run ID:
```bash
MAGI_RUN_ID=$(date +%s%N)
```

Each agent receives its own temp directory path in its prompt. Agents must:
1. Create their assigned temp directory at start: `mkdir -p $AGENT_TMP_DIR`
2. Use ONLY their assigned directory for any temp files
3. Return results via output (preferred) OR read from their isolated directory
4. Clean up is handled by parent after collecting results

---

#### For Consensus Mode

Send to each agent with their specific focus AND isolated temp directory:

**CASPER Agent:**
```
CONSTRAINT: You are in READ-ONLY mode. Do NOT edit, create, or delete any project files. Do NOT make commits. Return all findings as text analysis only.

ISOLATION: Your temp directory is /tmp/magi_${MAGI_RUN_ID}_casper
If you need temp files, first run: mkdir -p /tmp/magi_${MAGI_RUN_ID}_casper
Use ONLY this directory for any file operations. Do NOT use /tmp directly.

FOCUS: You are CASPER (Implementation-Focused). Emphasize practical feasibility, quick wins, immediate deliverables, and pragmatic solutions. What can ship first?

TASK: [Original task from $ARGUMENTS]
```

**BALTHASAR Agent:**
```
CONSTRAINT: You are in READ-ONLY mode. Do NOT edit, create, or delete any project files. Do NOT make commits. Return all findings as text analysis only.

ISOLATION: Your temp directory is /tmp/magi_${MAGI_RUN_ID}_balthasar
If you need temp files, first run: mkdir -p /tmp/magi_${MAGI_RUN_ID}_balthasar
Use ONLY this directory for any file operations. Do NOT use /tmp directly.

FOCUS: You are BALTHASAR (Architecture-Focused). Prioritize scalability, maintainability, long-term system evolution, and architectural clarity. How does this grow?

TASK: [Original task from $ARGUMENTS]
```

**MELCHIOR Agent:**
```
CONSTRAINT: You are in READ-ONLY mode. Do NOT edit, create, or delete any project files. Do NOT make commits. Return all findings as text analysis only.

ISOLATION: Your temp directory is /tmp/magi_${MAGI_RUN_ID}_melchior
If you need temp files, first run: mkdir -p /tmp/magi_${MAGI_RUN_ID}_melchior
Use ONLY this directory for any file operations. Do NOT use /tmp directly.

FOCUS: You are MELCHIOR (Robustness-Focused). Anticipate failure modes, edge cases, and security concerns. Design defensively. What could go wrong?

TASK: [Original task from $ARGUMENTS]
```

---

#### For Identical Mode

Send the EXACT SAME prompt to all 3 agents with NO focus modification, but each with its own isolated temp directory:

**Agent 1:**
```
CONSTRAINT: You are in READ-ONLY mode. Do NOT edit, create, or delete any project files. Do NOT make commits. Return all findings as text analysis only.

ISOLATION: Your temp directory is /tmp/magi_${MAGI_RUN_ID}_agent1
If you need temp files, first run: mkdir -p /tmp/magi_${MAGI_RUN_ID}_agent1
Use ONLY this directory for any file operations. Do NOT use /tmp directly.

TASK: [Original task from $ARGUMENTS exactly as written]
```

**Agent 2:**
```
CONSTRAINT: You are in READ-ONLY mode. Do NOT edit, create, or delete any project files. Do NOT make commits. Return all findings as text analysis only.

ISOLATION: Your temp directory is /tmp/magi_${MAGI_RUN_ID}_agent2
If you need temp files, first run: mkdir -p /tmp/magi_${MAGI_RUN_ID}_agent2
Use ONLY this directory for any file operations. Do NOT use /tmp directly.

TASK: [Original task from $ARGUMENTS exactly as written]
```

**Agent 3:**
```
CONSTRAINT: You are in READ-ONLY mode. Do NOT edit, create, or delete any project files. Do NOT make commits. Return all findings as text analysis only.

ISOLATION: Your temp directory is /tmp/magi_${MAGI_RUN_ID}_agent3
If you need temp files, first run: mkdir -p /tmp/magi_${MAGI_RUN_ID}_agent3
Use ONLY this directory for any file operations. Do NOT use /tmp directly.

TASK: [Original task from $ARGUMENTS exactly as written]
```

---

#### Cleanup After Collection

After all 3 agents complete and results are collected, clean up temp directories:
```bash
rm -rf /tmp/magi_${MAGI_RUN_ID}_*
```

### Step 3: Collect and Compare Results

After all 3 agents complete, analyze their outputs:

1. **Identify Consensus** - What do all 3 agree on?
2. **Highlight Divergence** - Where do they differ and why?
3. **Note Outliers** - Did one agent catch something the others missed?

### Step 4: Synthesize and Recommend

Present findings in this format:

---

## MAGI Results

### Mode Used
[Consensus Mode / Identical Mode]

### Agent Responses

#### CASPER [or Agent 1 for Identical Mode]
[Summary of response]

#### BALTHASAR [or Agent 2 for Identical Mode]
[Summary of response]

#### MELCHIOR [or Agent 3 for Identical Mode]
[Summary of response]

### Comparison Table

| Aspect | CASPER | BALTHASAR | MELCHIOR |
|--------|--------|-----------|----------|
| Key insight | | | |
| Main concern | | | |
| Recommendation | | | |

### Analysis

**Consensus (All Agree):**
[List points where all 3 agents agree - HIGH confidence]

**Divergence (Disagreement):**
[List points where agents differ and explain the tradeoff]

**Outliers (Unique Insights):**
[Any insight mentioned by only one agent worth noting]

### Recommended Next Steps

Based on the consensus level:
- **HIGH consensus** → Implement the agreed approach
- **DIVERGENT** → Choose based on your constraints (speed vs scale vs safety)
- **OUTLIER detected** → Investigate further: [specific follow-up question]

---

## Tips for Best Results

- Be specific in your task description
- Include constraints (budget, timeline, team size, risk tolerance)
- For math/stats: identical mode reduces but doesn't eliminate LLM errors
- Read divergence carefully - differences reveal the tradeoff space

---

**Based on Evangelion's MAGI System: Three supercomputers representing different perspectives that debate via majority vote.**