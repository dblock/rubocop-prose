# Markdown/ShellPrompts

In configured shell-language fenced blocks, remove each command's leading `$` and following space only when every nonblank line starts with that prompt. Blank lines are preserved. Corrections retain list and quote container prefixes.

Any output or unprompted continuation makes the entire block ineligible. If removing prompts could expose a closing fence inside the example, all offenses in that block are report-only. Unlabeled and indented blocks are deliberately ignored, and shell languages are explicitly configurable and case-sensitive. Root prompts (`#`) and other prompt formats are not interpreted.

## Configuration

```yaml
Markdown/ShellPrompts:
  Enabled: false
  ShellLanguages: # Case-sensitive fenced language names.
    - bash
    - console
    - ksh
    - sh
    - shell
    - zsh
```

## Example

### Bad

````markdown
```sh
$ echo hello
```
````

### Good

````markdown
```sh
echo hello
```
````
