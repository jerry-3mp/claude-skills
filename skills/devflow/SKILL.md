---
name: devflow
description: Guided feature development with systematic phases (warm up, clarify, architecture, plan, implement). Uses MAGI 3-way consensus for architecture design with verification against codebase patterns.
---

# DevFlow: Guided Feature Development

A structured workflow for implementing features systematically, from discovery through deployment. This workflow ensures requirements are clear, architecture is sound, and implementation follows project conventions.

## Quick Start

Invoke with your feature or task:

```
/devflow Implement dark mode toggle in settings panel
/devflow Add filtering to analytics dashboard
/devflow PROJ-100 User Activity Report
```

---

## The Five Phases

### Phase 1: Warm Up (Discovery & Pattern Recognition)

**Goal**: Understand the problem space by examining existing code and recent work.

Before diving into implementation, build context:

1. **Review Related PRs** — Find recent work in similar areas
2. **Check Local Docs** — Look for documented patterns in `local/docs/`
3. **Identify Existing Patterns** — Find similar features in the codebase
4. **Summarize Findings** — Document key patterns and conventions

**Tools**: Glob, Grep, Read

---

### Phase 2: Clarify Requirements (Interactive Discovery)

**Goal**: Understand exactly what you're building by asking one question at a time.

**CRITICAL RULES**:
- Use `AskUserQuestion` tool to clarify requirements
- **Ask ONE question at a time** — NEVER multiple questions in a single prompt
- **NEVER assume UI structure** — Don't assume tables, cards, modals, etc.
- Wait for user's answer before asking the next question

**Question Flow** (ask in order, skip if already clear):

1. **High-level structure** — "What should this page/tab contain?"
2. **For each component**:
   - What data should it show?
   - What are the column/field names?
   - What interactions are needed? (sorting, filtering, export)
3. **Edge cases**:
   - Empty state handling?
   - Pagination needed?
   - Date range filtering?

**Anti-Patterns to Avoid**:

| Bad | Good |
|-----|------|
| "I'll create a table with columns A, B, C" | "What columns should this table have?" |
| Asking 5 questions at once | Ask one, wait for answer, then ask next |
| "Here are my assumptions..." | "What is the expected behavior for X?" |

**Tools**: AskUserQuestion

---

### Phase 3: Architecture (Design with MAGI Consensus)

**Goal**: Design the implementation with verified, pattern-aligned recommendations.

**Step 1: Run MAGI 3-Way Analysis**

Use `/feature-dev:feature-dev` to run MAGI-style 3-way parallel exploration:

```
/feature-dev:feature-dev

Designing architecture for: [feature description]

Codebase patterns found in Phase 1:
- [Key patterns]

User requirements from Phase 2:
- [Clarified requirements]

Explore from three perspectives:
1. CASPER (Implementation) — Practical, quick-win focused
2. BALTHASAR (Architecture) — Patterns, scalability, maintainability
3. MELCHIOR (Robustness) — Edge cases, error handling, defensive programming
```

**Step 2: Verify Against Codebase Patterns**

**CRITICAL: All 3 MAGI agents can be wrong if they recommend theoretical patterns over actual codebase patterns.**

After MAGI analysis:

1. **Check each recommendation** against actual code
2. **Compare to existing implementations** — Find similar features
3. **Verify against project conventions** — CLAUDE.md, style guides, existing patterns
4. **Red flags to catch**:
   - MAGI suggests a pattern not found anywhere in the codebase
   - MAGI recommends creating a new directory structure
   - Suggestion contradicts documented project conventions

5. **Default to existing patterns** unless there's a documented reason to break them

**Step 3: Create Pattern Decision Table**

| Component | MAGI Recommendation | Existing Pattern | Decision | Rationale |
|-----------|--------------------|--------------------|----------|-----------|
| Metrics Card | Aggregator class | Aggregator class | Follow existing | Consistency |
| Leaderboard | Aggregator class | Inline controller | **Follow existing** | Consistency over theory |

Use `AskUserQuestion` to confirm pattern decisions with the user if MAGI differs from existing patterns.

**Tools**: Grep, Read, AskUserQuestion

---

### Phase 4: Planning (Document Implementation)

**Goal**: Create a detailed, verifiable implementation plan.

Create a plan document in `local/docs/<ticket>/`:

```bash
mkdir -p local/docs/<ticket>/
```

**Implementation Plan Structure**:

```markdown
# <Ticket>: <Feature Name> Implementation Plan

> **Date**: YYYY-MM-DD
> **Status**: Ready for Implementation
> **Depends On**: <Related PRs or tickets>

## Overview
Brief description.

## Requirements Summary
From Phase 2.

## Pattern Decisions
Table from Phase 3 with rationale.

## Implementation Steps
Step-by-step with file paths and code snippets.

## Files to Create
| File | Purpose |

## Files to Modify
| File | Changes |

## Testing Plan
- Unit tests
- Component previews
- Manual testing steps
```

**Tools**: Read, Write

---

### Phase 5: Implementation (Execute & Commit)

**Goal**: Build the feature incrementally, following the plan.

**Workflow**:

1. **Follow the Plan** — Don't deviate without discussing with user
2. **Commit Incrementally** — Small, focused commits
3. **Verify Each Step** — Matches existing patterns, has tests/previews
4. **Commit Messages** — Follow `git-conventions.md`, use `/charcount` to verify length
5. **Internationalization** — Follow `locale-workflow.md` (en.yml first, then other locales)

**Final Verification Checklist**:
- [ ] All files from plan created/modified
- [ ] Tests pass (run your project's test suite)
- [ ] Linter passes (run your project's linter)
- [ ] Previews/storybook work (if applicable)
- [ ] Manual testing completed

**Tools**: Read, Write, Edit, Bash, Grep

---

## Key Principles

### 1. Ask, Don't Assume
- Never assume UI structure (is it a table? Cards? Modals?)
- Always ask ONE question at a time using `AskUserQuestion`
- Wait for answer before asking next question

### 2. MAGI + Verification
- Use `/feature-dev:feature-dev` for 3-way architecture analysis
- **Always verify** MAGI recommendations against actual codebase patterns
- All 3 agents can be wrong if they ignore existing patterns
- Default to existing patterns unless explicitly justified

### 3. Patterns Over Theory
- Find similar features already in the codebase
- Copy their structure, naming, and organization
- Only innovate if the codebase doesn't have a pattern for it

### 4. Incremental Development
- Create/modify one file at a time
- Test and verify after each step
- Commit logically (not one massive commit)

### 5. Documentation First
- Plan before coding
- Write the Phase 4 plan in `local/docs/<ticket>/`
- Keep it updated if requirements change

---

## When to Use DevFlow

- Building new features (campaigns, analytics dashboards, reports)
- Adding significant UI components or sections
- Implementing complex logic requiring architecture decisions
- Refactoring large features

## When NOT to Use DevFlow

- Small bug fixes (just fix it)
- Minor UI tweaks or styling
- Simple one-off changes
- When you already have a clear implementation plan

---

## Lessons Learned

1. **Don't assume UI structure** — Ask first: "how do you know this tab contains a table? Maybe no table, or multiple tables."
2. **Ask questions one by one** — Not all at once
3. **Check existing patterns** — MAGI may recommend patterns that differ from what the codebase actually uses
4. **Verify MAGI against reality** — All 3 MAGI agents can be wrong if they favor theory over existing code
5. **Consistency over theory** — Follow existing patterns unless there's a documented reason to break them

---

## Resources

- **CLAUDE.md**: Project-specific patterns and setup instructions
- **Git Conventions**: `rules/git-conventions.md`
- **I18n Workflow**: `rules/locale-workflow.md`
- **Local Docs**: `local/docs/` for feature-specific architecture decisions