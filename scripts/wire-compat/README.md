# Wire compatibility

Older apps and servers keep sending and expecting the JSON they were built with. Two checks run on every PR (`.github/workflows/wire-compat.yml`):

- `diff_warnings.py <base-ref>` warns (never fails) about a new required property with no default in a Codable type, a removed or renamed property, a new Codable enum case, and a removed or renamed contract.
- `WireSampleTests` decodes every saved sample in `Tests/FrontBackModelsTests/WireCompat/Samples` with the current types. A failure means older clients would break.

When you add or change a contract:

```sh
python3 scripts/wire-compat/generate_contract_list.py
WIRE_SAMPLES_RECORD=1 swift test --filter WireSampleTests   # writes samples for new contracts only
```

Never edit or delete an existing sample to make the test pass, unless you mean to drop support for older clients.
