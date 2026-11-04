# Markdown/ShellPrompts

Removes leading `$` and `%` prompts followed by a space in shell-language fences by default. Every nonblank line other than a shell comment must start with a configured prompt. Blocks containing output or unprompted continuation lines are left alone; comments, blank lines, and nesting are preserved.

`Prompts` is a positive set of literal markers, not an allowed/forbidden pair. An explicit list replaces the defaults. Markers must be nonempty strings without whitespace; the list must contain at least one marker. Language names are case-sensitive.

`#` is not a default prompt: shell comments are never stripped. When explicitly configured, `#` prompts are reported, but the entire block remains uncorrected because commands cannot reliably be distinguished from comments. The same safeguard applies to any configured marker beginning with `#`. Corrections are also withheld if removing any prompt could expose a closing fence.

## Configuration

```yaml
Markdown/ShellPrompts:
  Enabled: true
  Prompts:
    - '$'
    - '%'
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
% echo hello
# Keep this shell comment.
```
````

### Good

````markdown
```sh
echo hello
echo hello
# Keep this shell comment.
```
````

For this configuration:

```yaml
Markdown/ShellPrompts:
  Prompts:
    - '%'
    - '#'
```

Both `% echo hello` and `# echo hello` are reported in shell-language fences. A block containing `# echo hello` or `# Keep this shell comment.` is report-only; neither line is silently rewritten. `$` is no longer recognized as a prompt with this configuration.
