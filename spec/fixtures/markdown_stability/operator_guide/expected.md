# Operator guide

Use *literal* examples and **exact** commands. The [API guide](https://example.test/api?q=a%20b#response "API reference") explains `response.body`.

```ruby
puts "first  value"
puts "[literal](not-a-link) and *not emphasis*"
```

## Results

The table keeps its links, image destinations, and cell order.

| Result     | Evidence                                          |
| ---        | :---:                                             |
| *ready*    | [build](https://example.test/build/42 "Build 42") |
| **signed** | ![seal](images/seal.svg "Release seal")           |

### Audit

```ruby
values = ["café", "two  spaces"]
puts values.join("\n")
```

After the code, keep this hard break.\
This is still the same paragraph, not part of the code or table.
