# Markdown/ListItemPunctuation

Requires, forbids, or consistently uses terminal punctuation in parsed Markdown list items. Terminal punctuation is a period, exclamation mark, question mark, or ellipsis. Punctuation characters may differ; for example, a question and a statement are consistent. A closing quotation mark after punctuation is allowed. Inline Markdown formatting does not affect the check.

With `EnforcedStyle: consistent`, the first item sets the expected style. `always` requires terminal punctuation on every checked item, including single-item lists; `never` forbids it. Nested lists are checked independently. The cop reports only and checks a list only when every item consists of one parsed paragraph; items with code blocks, multiple blocks, or other ambiguous structure are skipped.

## Configuration

```yaml
Markdown/ListItemPunctuation:
  Enabled: false
  EnforcedStyle: consistent # consistent, always, or never
  AllowedPunctuation:
    - "."
    - "!"
    - "?"
    - "…"
```

`AllowedPunctuation` restricts the recognized terminal characters (`.`, `!`, `?`, and `…`). Every character in the terminal punctuation sequence must be allowed, so a period-only policy rejects both `.?` and `?.`. It does not introduce new punctuation characters. In `consistent` mode, this restriction applies to punctuated items without requiring punctuation on an entirely unpunctuated list. `never` forbids all recognized terminal punctuation regardless of this setting.

## Example

For this configuration:

```yaml
Markdown/ListItemPunctuation:
  Enabled: true
  EnforcedStyle: always
```

### Bad

```markdown
- Build the package
- Run the tests
```

### Good

```markdown
- Build the package.
- Is it ready?
```

## Require Periods

For this configuration:

```yaml
Markdown/ListItemPunctuation:
  Enabled: true
  EnforcedStyle: always
  AllowedPunctuation:
    - "."
```

### Bad

```markdown
- Build the package!
- Run the tests
```

### Good

```markdown
- Build the package.
- Run the tests.
```
