# Markdown/ThematicBreakStyle

Enforces one configured thematic-break spelling, permits a configured list of spellings, or follows the first break's exact spelling in consistent mode. Autocorrection preserves indentation and blockquote nesting; when a list permits multiple spellings, invalid breaks are reported without correction because their intended meaning is ambiguous.

## Configuration

```yaml
Markdown/ThematicBreakStyle:
  Enabled: true
  Style: consistent
```

`Style` accepts `consistent`, a literal Markdown thematic break such as `- - -`, or a nonempty array of literal breaks. Each literal must contain at least three matching `*`, `-`, or `_` markers, optionally separated by spaces or tabs, without leading or trailing whitespace. There is no finite `SupportedStyles` list.

## Example

For this configuration:

```yaml
Markdown/ThematicBreakStyle:
  Style:
    - '---'
    - '-----'
```

### Incorrect

```markdown
Before.

***

After.
```

### Correct

```markdown
Before.

---

Between.

-----

After.
```

Both configured spellings are accepted. A disallowed spelling is reported but not automatically replaced when multiple alternatives are configured.
