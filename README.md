# Storyteller

version 0.4.2.2

Run user stories based on a simple DSL

User stories or Use Cases can be written in a procedural way, like a recipe, to increase the understanding of the problem.

### Start

Extend the class 

`class MyUseCase < Storyteller::Story`

Define its parameters, Storyteller uses SmartInit to do so

    class MyUsecase < Storyteller::Story
      initialize_with :param1, :param2
    end

It is recommended that every parameter is to set each Story parameter to be objects or native types, the ones that can be easier to load.


### Preparation

After initializing the Story, if any other element should be loaded, preparation steps can be added.

    class MyUsecase < Storyteller::Story
      initialize with :comment, user_id

      prepare :load_user

      private

      def load_user
        @user = User.find(user_id)
      end
    end

### Requisites

To ensure the correct execution of the steps, validations can be added in the form of requisites.

Each requisite must implement its own verification method, the outcome can have two ways.

The first and faster is returning false if the requisite is not fulfilled.
The second and recommended is to fill in the error description using `error(element, kind)` to give 
information to the user about the whereabouts of the error.

    class MyUseCase < Storyteller::Story

      requisite :membership_active?

      private
      
      def membership_active?
        error(:membership, :not_active) unless membership.active?
      end
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

Every Story **must** have at least on step to be able to execute, if no steps are added, the validation process will halt the Story's execution.

### Verification

Verification steps can be added to check if the Story has concluded successfully.



## Lifecycle

  - initialization
    - `initialize_with`
  - preparation
    - `prepare`
  - validation
    - `requisite`, `validate`
  - execution
    - `step`
  - verification
    - `done_criteria`


## Helper methods

Other methods are included to help define the story

**name** can be used to give the Story a more user story name 

**subject** can be used to define which is the main user of a story, so any other method can refer to that user as subject
    
    class BookClosestToMe < Story
      name 'As a user I want to make a reservation in a restaurant closest to me'
      subject :creator

      def creator = user

    end




## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add storyteller

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install storyteller

## Usage

Require the gem, if needed 

`require storyteller`

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

You can learn more about the making process by visiting [AvispaTech's development blog on the subject](https://blog.avispa.tech/2022/08/01/storyteller-1.html).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/avispatech/storyteller. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/storyteller/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Storyteller project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/storyteller/blob/main/CODE_OF_CONDUCT.md).
