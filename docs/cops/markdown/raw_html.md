# Markdown/RawHtml

Reports HTML elements outside the configured allowlist, including nested elements and table cells. Only opening tags are checked; comments are ignored. Element names and attribute names are case-insensitive.

`AllowedElements` accepts plain element names and attribute allowlists in the same list. A plain name permits that element with any attributes or none. An attribute list permits zero or more of the listed attributes and rejects every unlisted attribute. Elements not listed are rejected.

This is a lint policy, not an HTML sanitizer or security guarantee. Attribute values are not checked, and no automatic correction is offered.

## Configuration

```yaml
Markdown/RawHtml:
  Enabled: false
  AllowedElements: []
```

## Examples

### Disallow all HTML

For this configuration:

```yaml
Markdown/RawHtml:
  Enabled: true
  AllowedElements: []
```

#### Bad

```markdown
<b>Important</b>

<img src="chart.png" alt="Results">
```

#### Good

```markdown
**Important**

![Results](chart.png)
```

### Allow an element with or without attributes

For this configuration:

```yaml
Markdown/RawHtml:
  Enabled: true
  AllowedElements:
    - br
    - img
```

#### Bad: an unlisted element

```markdown
<div>Results</div>
```

#### Good: attributes are optional and unrestricted

```markdown
Text<br>More text.

<img src="chart.png" alt="Results">

<img src="chart.png" alt="Results" width="320" height="200">
```

### Allow only specific attributes

For this configuration:

```yaml
Markdown/RawHtml:
  Enabled: true
  AllowedElements:
    - br
    - img:
        - src
        - alt
        - width
        - height
        - style
```

#### Bad: an unlisted attribute, even alongside allowed ones

```markdown
<img src="chart.png" alt="Results" loading="lazy">

<img src="chart.png" width="320" data-note="width=320">
```

#### Good: zero or more allowed attributes

```markdown
![Results](chart.png)

Text<br>More text.

<img>

<img src="chart.png" alt="Results">

<img src="chart.png" alt="Results" width="320">

<img src="chart.png" alt="Results" height="200">

<img src="chart.png" alt="Results" style="width: 50%">
```

### Matching rules

Each attribute-rule entry maps one element name to a list of permitted attribute names. None are required. An empty attribute list permits only tags with no attributes. Attribute values are not checked: `width="320"` and `width="50%"` are both permitted when `width` is listed. `data-note="width=320"` is rejected unless `data-note` itself is listed.

Each opening tag is checked independently, including nested elements: allowing `img` does not allow a surrounding `div`. If multiple entries match the same element, satisfying any entry is enough; adding a plain `img` entry therefore removes attribute restrictions for `img`. Keep only the attribute-list entry when attributes must be restricted.
