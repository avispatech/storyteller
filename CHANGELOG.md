## [0.4.3] - 2023-02-07

Modifies prepares_with to be an alias of prepare
Condenses code
Cleaning by rubocop on `spec/` and `lib/`
## [0.4.2] - 2022-08-15

Adds rubocop rules
Runs rubocop against code 
Requisite is the official way to validate
Verify is the official way to check for done criteria


## [0.4.0] - 2022-08-10

- adds tests for prerequisites
- adds tests for steps
- adds tests for valid?
- adds tests for success?
- modifies requisite with prerequisite
- modifies prepares_with with requisite

## [0.3.1] - 2022-08-10

- `requisite :callback` replaces `validates_with :callback` as the official
  way to determine the minimum conditions to start a sotry.

## [0.3.0] - 2022-08-10

- Adds done criteria, and verification process

## [0.2.0] - 2022-08-02

- Uses ActiveSuport::Callbacks to process callbacks
- Tests for step existence and validation added

## [0.1.0] - 2022-08-01

- Initial release
