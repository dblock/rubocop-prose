# Markdown/OutsideSpacing

Reports inline code and emphasis that directly touch a neighboring prose word. It checks Unicode letters and numbers using original character positions and leaves boundaries in scripts commonly written without spaces, such as CJK, unchanged.

The cop reports only and never inserts spaces: source text cannot establish whether adjoining letters form separate words or intentional intraword formatting, and changing adjacency can alter meaning. Such cases are left as written and can be resolved by editing the source or disabling this cop for the relevant files.

## Configuration

```yaml
Markdown/OutsideSpacing:
  Enabled: true
```

## Example

### Bad

```markdown
Use`command`now; read**important**text.
```

### Good

```markdown
Use `command` now; read **important** text.
```
