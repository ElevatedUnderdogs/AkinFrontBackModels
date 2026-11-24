# Wire compatibility

Older apps and servers keep sending and expecting the JSON they were built with. Two checks run on every PR (`.github/workflows/wire-compat.yml`):

- `diff_warnings.py <base-ref>` is the main guard. It warns (never fails) about a new required property with no default in a Codable type, a removed or renamed property, a new Codable enum case, and a removed or renamed contract.
- `WireSampleTests` decodes the saved samples in `Tests/FrontBackModelsTests/WireCompat/Samples` with the current types.

Samples are kept only for types with their own decoding logic (a hand-written `init(from:)`, custom keys, dates or enum handling), and only when they raise code coverage. Synthesized Codable is Apple's job, so it gets no samples.

To add one, save a real payload or response as `<path>.<n>.<payload|response>.json`, then confirm coverage goes up:

```sh
swift test --enable-code-coverage --filter WireSampleTests
```

If the contract list is out of date, run `python3 scripts/wire-compat/generate_contract_list.py`. Don't edit an existing sample to make the test pass unless you mean to drop support for older clients.
