# Locale Keys Workflow

## Why This Workflow?

Rails i18n requires careful coordination across locale files. This workflow ensures:
- **Single source of truth** — en.yml defines all keys and structure first
- **Consistency** — Other locales mirror the English structure exactly
- **Quality translations** — Context-aware translations, not literal word-for-word
- **Reduced errors** — Translations validate against complete en.yml

## Supported Locales (9 total)

| Code | Language | Priority |
|------|----------|----------|
| `en` | English | **Primary** (source of truth) |
| `es` | Spanish | Secondary |
| `fr-CA` | French (Canada) | Secondary |
| `fr-FR` | French (France) | Secondary |
| `he` | Hebrew | Secondary |
| `ja` | Japanese | Secondary |
| `tr` | Turkish | Secondary |
| `zh-CN` | Chinese (Simplified) | Secondary |
| `zh-TW` | Chinese (Traditional) | Secondary |

---

## Phase 1: English (en.yml)

### Step 1: Create/modify en.yml first
- Add all required keys with proper YAML nesting
- Use clear, context-appropriate English values
- Follow existing structure patterns in the folder

### Step 2: Validate YAML syntax
```bash
ruby -ryaml -e "YAML.load_file('path/to/en.yml')"
```

### Step 3: Confirm en.yml is complete before proceeding
- All keys present
- Proper nesting structure
- No placeholder text

---

## Phase 2: Secondary Locales

### Step 1: Discover existing locales in the same folder
```bash
ls config/locales/views/FEATURE_NAME/ | grep -v en.yml
```

### Step 2: For each locale file, translate from en.yml
- Copy the exact key hierarchy from en.yml
- Replace the root key (`en:` → `es:`, `fr-CA:`, etc.)
- **Translate values contextually** — Consider how the text is used in the UI
- Avoid literal word-for-word translations that sound unnatural
- Keep technical terms or proper nouns unchanged when appropriate

### Step 3: Process in this order
1. `es.yml`
2. `fr-CA.yml`
3. `fr-FR.yml`
4. `he.yml`
5. `ja.yml`
6. `tr.yml`
7. `zh-CN.yml`
8. `zh-TW.yml`

---

## Key Principles

1. **Never modify secondary locales before en.yml is complete**
2. **Structure must match** — Every key in en.yml must exist in all other locales
3. **Root key must match locale code** — `es:` for es.yml, `ja:` for ja.yml, etc.
4. **Context-aware translations** — Translate based on UI context, not literally

---

## Example Structure

**en.yml** (source):
```yaml
en:
  feature:
    title: Page Title
    description: Some description
    buttons:
      save: Save
      cancel: Cancel
```

**es.yml** (translated):
```yaml
es:
  feature:
    title: Título de la página
    description: Alguna descripción
    buttons:
      save: Guardar
      cancel: Cancelar
```

---

## Verification

Before committing, validate all locale files:
```bash
for f in config/locales/views/FEATURE_NAME/*.yml; do
  echo "Checking $f..."
  ruby -ryaml -e "YAML.load_file('$f')" && echo "OK" || echo "INVALID"
done
```

---

## Commit Message

Per git-conventions.md, use:
```
feat(i18n): add locale keys for <feature-name>
```

Use `/charcount` to verify under 72 characters.