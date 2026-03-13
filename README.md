# Branch Commit Buildkite Plugin 

A Buildkite plugin to check that the build commit is on the set branch

## Options

These are all the options available to configure this plugin's behaviour.

### Required

#### `mode` (string)

This can be either `warn` or `strict`.
 
- `warn` will output a warning that the current set `BUILDKITE_BRANCH` is not where the build commit is located but continue the build
- `strict` will fail the build in the above scenario

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

In `strict` mode:

```yaml
steps:
  steps:
    - label: ":pipeline:"
      command: buildkite-agent pipeline upload
      plugins:
        - branch-commit#v1.0.0:
            mode: "strict"
```

## ⚒ Developing

You can use the [bk cli](https://github.com/buildkite/cli) to run the [pipeline](.buildkite/pipeline.yml) locally:

```bash
bk local run
```

## 👩‍💻 Contributing

Your policy on how to contribute to the plugin!

## 📜 License

The package is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
