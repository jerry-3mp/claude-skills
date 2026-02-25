Suggest few commit message options for attached git diff output (full diff or --name-status), each is within 72 chars within 72 chars and following Conventional Commits 1.0.0 format
- Pattern: `<type>[optional scope]: <description>`
- **Must be single-line only** (no multi-line descriptions or bullet points)
- Maximum 72 characters
- Be concise and specific
- Examples:
    - Good: `feat(campaigns): add automated recipient assignment by group`
    - Good: `fix(auth): handle expired SAML sessions gracefully`
    - Bad: Multi-line commits with bullet point lists
