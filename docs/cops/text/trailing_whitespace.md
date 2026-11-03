# Text/TrailingWhitespace

Disabled by default. Removes all trailing spaces and tabs from `.txt` lines, including whitespace-only lines. Plain text has no Markdown hard breaks, code fences, metadata exclusions, or hidden HTML directives. This cop never inspects Markdown; use `Markdown/TrailingWhitespace` to preserve its hard-break semantics.

## Examples

```yaml
Text/TrailingWhitespace:
  Enabled: true
```

Inputs are shown as Ruby strings so trailing whitespace and newline characters are visible.

### Bad

```ruby
"A paragraph.  \n"
```

### Good

```ruby
"A paragraph.\n"
```
