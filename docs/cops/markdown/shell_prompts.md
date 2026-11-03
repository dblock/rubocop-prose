# Markdown/ShellPrompts

Removes leading `$` prompts followed by a space when every nonblank line in a shell-language fence starts with one. Blocks containing output or unprompted continuation lines are left alone; blank lines and nesting are preserved.

Corrections are withheld if removing prompts could expose a closing fence. Language names are case-sensitive.

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
