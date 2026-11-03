# Markdown/DescriptiveLinkText

Reports links whose entire rendered label matches a configured generic label, ignoring case and repeated whitespace. Prefer descriptive text such as `[the installation guide](https://example.test)`.

Optionally set `NonDescriptiveWords` to reject nonempty labels made entirely of listed words, such as `click this link`. Words are separated by whitespace; punctuation remains part of a word. A label containing any other word is accepted unless it matches `GenericLabels`.

Images and autolinks are not checked. Report-only.

## Configuration

```yaml
Markdown/DescriptiveLinkText:
  Enabled: true
  GenericLabels: # Whole labels; customize for the project's language.
    - click here
    - here
    - link
    - more
  NonDescriptiveWords: [] # Optional individual words; both lists empty permits every label.
```

## Example

For this configuration:

```yaml
Markdown/DescriptiveLinkText:
  NonDescriptiveWords:
    - click
    - this
    - link
```

### Bad

```markdown
[click this link](/guide)
```

### Good

```markdown
[Read the installation guide](/guide)
```
