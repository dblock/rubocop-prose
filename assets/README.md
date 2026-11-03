# Logo artwork

`rubocop-logo.svg` is an unchanged copy of [the official website's SVG](https://github.com/rubocop/rubocop.org/blob/e48d295d87264ea7dbfa0c6df7c7c4b56670979d/src/images/favicon.svg), reused from [rubocop-spellcheck's logo PR](https://github.com/dblock/rubocop-spellcheck/pull/31). The upstream conversion uses paths from RuboCop's original MIT-licensed vector artwork. Its copyright and permission notice is preserved in [RUBOCOP-LICENSE](RUBOCOP-LICENSE).

`logo.svg` places that artwork alongside a newly drawn parchment scroll, replacing rubocop-spellcheck's pencil with rolled paper and lines of prose. The scroll uses the repository's MIT license. A white background keeps the original black emblem visible on dark pages. Keep `rubocop-logo.svg` beside the composition when editing or rendering it.

`logo.png` is the 512px rendered README image, displayed at 160px. Regenerate it with:

```sh
rsvg-convert assets/logo.svg -o assets/logo.png
```
