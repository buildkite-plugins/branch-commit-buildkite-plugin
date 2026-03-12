# Branch Commit Buildkite Plugin

A Buildkite plugin that verifies the build commit exists on the specified branch. Designed for UI-triggered builds where a user may select a commit that doesn't belong to the target branch.

The plugin only runs when `BUILDKITE_SOURCE` is `ui`. For all other build sources it exits immediately.

## Options

### Optional

#### `mode` (string)

Controls what happens when the commit is not found on the branch. Defaults to `strict`.

- `warn` — logs a warning and continues the build
- `strict` — fails the build with an error

## Examples

In `warn` mode:

```yaml
steps:
  - label: ":pipeline:"
    command: buildkite-agent pipeline upload
    plugins:
      - branch-commit#v1.0.0:
          mode: "warn"
```

In `strict` mode (the default — `mode` can be omitted):

```yaml
steps:
  - label: ":pipeline:"
    command: buildkite-agent pipeline upload
    plugins:
      - branch-commit#v1.0.0:
          mode: "strict"
```

## Developing

Run tests locally:

```bash
docker run -it --rm -v "$PWD:/plugin:ro" buildkite/plugin-tester
```

Run shellcheck:

```bash
docker run --rm -v "$PWD:/mnt" --workdir "/mnt" koalaman/shellcheck:stable hooks/* lib/*.bash
```

Validate plugin structure:

```bash
docker run -it --rm -v "$PWD:/plugin:ro" buildkite/plugin-linter --id branch-commit --path /plugin
```

## Contributing

1. Fork the repository and create a feature branch
2. Add tests for any new functionality
3. Ensure all tests pass and shellcheck reports no warnings
4. Open a pull request

## License

The package is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
