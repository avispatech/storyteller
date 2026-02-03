# AGENTS

This file provides project-specific guidance for AI agents working in this repository.

## Project Summary
Storyteller is a small Ruby gem that provides a DSL for executing user stories through a staged lifecycle using `ActiveSupport::Callbacks` and `SmartInit`.

## Repository Map
- `lib/storyteller.rb`: Core DSL and lifecycle logic (`Storyteller::Story`).
- `lib/storyteller/logger.rb`: Custom logger (silent mode warnings).
- `lib/storyteller/version.rb`: Version constant.
- `spec/storyteller_spec.rb`: Main RSpec coverage.
- `bin/setup`: Dependency installation.
- `bin/console`: Interactive console.
- `docs/`: Public documentation (site content).

## Commands
- Setup: `bin/setup`
- Tests: `bundle exec rake spec`
- Lint: `bundle exec rubocop`
- Default (tests + lint): `bundle exec rake`

## Development Conventions
- Keep the lifecycle order intact: init → preparation → validation → run → verification → after_run.
- A story must define at least one `step`; validation should fail otherwise.
- Respect `silent_story: true` by skipping `after_run` callbacks and logging a warning.
- Prefer adding or updating tests in `spec/storyteller_spec.rb` when changing behavior.
- Update `CHANGELOG.md` for user-visible behavior changes.

## When Editing
- Prefer minimal, focused changes that preserve the DSL surface.
- Avoid breaking compatibility with existing callback names (`requisite`, `validate`, `verify`, `done_criteria`).

## Release Notes
- Version lives in `lib/storyteller/version.rb`.
- Releases are handled by `bundle exec rake release`.

## If Unsure
- Read `README.md` and `docs/DEVELOPERS.md` before making structural changes.
