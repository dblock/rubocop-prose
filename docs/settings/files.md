# File selection

`Markdown/Include` and `Text/Include` select files using RuboCop's normal filename and glob patterns.

## Example

```yaml
Markdown:
  Include:
    - '**/*.md'
    - '**/*.markdown'
    - '**/*.notes'
Text:
  Include:
    - '**/*.txt'
    - '**/*.text'
```

Lists replace the inherited patterns for their format; omit a list to inherit it, or use `[]` to disable that format. Per-directory configuration and `--config` work as usual.

The [default patterns](../../config/default.yml) recognize common Markdown extensions and `.txt`, including uppercase variants. Custom patterns are case-sensitive. A file matching both formats is a configuration error.

Matching files are discovered automatically, without `AllCops/Include`. Use exclusions to skip files:

```yaml
AllCops:
  Exclude:
    - '**/LICENSE.txt'
```

Pass `--force-exclusion` to apply exclusions to explicitly named command-line files too.

File patterns select the format, not which cops are enabled. `Prose/*` cops support both formats; `Markdown/*` and `Text/*` inspect only their own.
