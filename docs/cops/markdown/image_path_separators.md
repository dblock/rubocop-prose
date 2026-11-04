# Markdown/ImagePathSeparators

Checks local image destinations for backslashes used as path separators. The check applies to inline images and resolved reference-style images; ordinary links and unresolved references are not checked.

The cop corrects clear separators to forward slashes. Backslashes before Markdown-escapable ASCII punctuation, such as the parentheses in `diagram\(v2\).png`, are preserved. Consecutive backslashes before a path component are reported without correction because their intended meaning is ambiguous. External URI destinations are left unchanged.

## Configuration

Enabled by default with no options.

## Example

### Bad

```markdown
![Diagram](images\diagram.png)
```

### Good

```markdown
![Diagram](images/diagram.png)

![Versioned diagram](images/diagram\(v2\).png)
```

For this configuration:

```yaml
Markdown/ImagePathSeparators:
  Enabled: false
```
