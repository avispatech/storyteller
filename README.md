# Storyteller

version 0.2.0

Run user stories based on a simple DSL

User stories or Use Cases can be written in a procedural way, like a recipe, to increase the understanding of the problem.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add storyteller

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install storyteller

## Usage

Require the gem, if needed 

`require storyteller`

### Start

Extend the class 

`class MyUseCase < Storyteller::Story`

Define its parameters, Storyteller uses SmartInit to do so

    class MyUsecase < Storyteller::Story
      initialize_with :param1, :param2
    end

### Steps

A story is solved advancing steps you can define them via symbols or lambdas

    class MyUsecase < Storyteller::Story
      initialize_with :param1, :param2

      step :first_step
      step :second_step
      step -> () { @param1.save }

      def first_step
      end

      def second_step
      end
    end

### Validation

TODO

### Preparation

TODO

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/storyteller. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/storyteller/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Storyteller project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/storyteller/blob/main/CODE_OF_CONDUCT.md).
