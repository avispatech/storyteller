# Developer Guide

## Overview
Storyteller is a small Ruby gem that provides a DSL for running user stories via a callback-driven lifecycle. The core implementation lives in `lib/storyteller.rb`, with a custom logger in `lib/storyteller/logger.rb` and the gem version in `lib/storyteller/version.rb`.

Lifecycle stages and callbacks are implemented with `ActiveSupport::Callbacks`, and initialization is handled by `SmartInit`.

## Requirements
- Ruby >= 3.1
- Bundler

## Setup
```bash
bin/setup
```

## Running Tests
```bash
bundle exec rake spec
```

## Linting
```bash
bundle exec rubocop
```

## Default Task (Tests + Lint)
```bash
bundle exec rake
```

## Console
```bash
bin/console
```

## Project Layout
- `lib/storyteller.rb`: Main DSL and lifecycle implementation (`Storyteller::Story`).
- `lib/storyteller/logger.rb`: Custom logger used for silent mode warnings.
- `lib/storyteller/version.rb`: Gem version constant.
- `spec/`: RSpec tests.
- `bin/`: Developer scripts (`setup`, `console`).
- `docs/`: Public docs and website content.

## Key Behaviors
- Stories must define at least one `step` or validation will fail.
- `initialize_with` always injects `silent_story: false` by default.
- `execute` runs lifecycle callbacks in order: init, preparation, validation, run, verification, after_run.
- When `silent_story: true`, `after_run` callbacks are skipped and a warning is logged.

## Adding or Changing Features
1. Update the DSL or lifecycle logic in `lib/storyteller.rb`.
2. Add/adjust tests in `spec/storyteller_spec.rb`.
3. Run `bundle exec rake`.
4. Update `CHANGELOG.md` if behavior changes.

## Release Process
1. Update version in `lib/storyteller/version.rb`.
2. Update `CHANGELOG.md`.
3. Run:
```bash
bundle exec rake release
```

## Notes
- `requisite` is the canonical validation hook (aliases exist for compatibility).
- `verify` / `done_criteria` is used for post-execution success checks.
