# Markdown/ImageAltText

Reports inline and resolved reference images whose rendered alternative text is blank, including images nested in links. Full, collapsed, and shortcut reference syntax is recognized with case/whitespace-normalized IDs.

Add a meaningful description inside the image brackets. The rule is report-only and does not invent alt text or offer an exception for decorative images.

Code blocks/spans, front matter, HTML markup/comments/raw regions, and escaped image syntax are excluded. HTML `img` elements are not checked, and nonblank alt text is not assessed for quality; this is intentionally narrower than a general accessibility audit.

## Configuration

```yaml
Markdown/ImageAltText:
  Enabled: true
```

## Example

### Bad

```markdown
![](/logo.png)
```

### Good

```markdown
![Project logo](/logo.png)
```
