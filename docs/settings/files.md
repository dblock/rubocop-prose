# File selection

`Markdown/Include` and `Text/Include` select which files use each document format. They use native RuboCop file patterns, including filenames, directory patterns, and globbed extensions. `Markdown/IgnoreFrontMatter` can be configured alongside `Markdown/Include`.

## Example

```yaml
Markdown:
  Include:
    - '**/*.md'
    - '**/*.markdown'
    - '**/*.notes'
  IgnoreFrontMatter: true
Text:
  Include:
    - '**/*.txt'
    - '**/*.text'
```

These lists replace the configured patterns for their format; this example does not retain other Markdown aliases. Omit a list to inherit its value, or use `[]` to disable recognition of that format. RuboCop's normal configuration inheritance applies, including per-directory configuration and explicit `--config` selection.

The default Markdown patterns select `.md`, `.markdown`, `.mdown`, `.mdwn`, `.mkd`, `.mkdn`, `.mkdown`, `.livemd`, `.ronn`, `.scd`, and `.workbook`. The default text patterns select `.txt`. Default patterns use character classes to cover every uppercase/lowercase combination, such as `**/*.[mM][dD]` and `**/*.[tT][xX][tT]`.

Custom patterns follow RuboCop's native matching and path resolution, including case sensitivity. `**/*.notes` matches lowercase suffixes; `**/*.NOTES` matches uppercase suffixes. Patterns such as `**/LICENSE` can select extensionless files, and `**/*.md.erb` can select compound suffixes. Malformed pattern lists are configuration errors. A file matching both formats raises an explicit configuration error rather than choosing a parser arbitrarily.

Configured files participate in automatic discovery without additional `AllCops/Include` entries. Explicit filenames, stdin, and autocorrection use the same per-file classification. Removing a pattern stops prose recognition for files it alone matched; it does not prevent other RuboCop integrations or explicitly configured file patterns from selecting them.

Use native exclusions to skip entire files:

```yaml
AllCops:
  Exclude:
    - '**/LICENSE.txt'
```

Discovered files honor exclusions. Explicit command-line filenames follow RuboCop's native behavior; use `--force-exclusion` to exclude them too. Department-level or per-cop `Exclude` controls the corresponding cops, not unrelated departments or a preprocessor's extraction rules.

File patterns choose the document adapter, not which cops are enabled. Shared `Prose/*` policies support both formats; `Markdown/*` and `Text/*` only inspect their own format. A custom Markdown pattern does not add another markup dialect or change the Markdown grammar.
