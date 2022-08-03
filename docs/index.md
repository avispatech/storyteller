# Storyteller

User stories or Use Cases can be written in a procedural way, like a recipe, to increase the understanding of the problem

Install it via Gemfile

`gem 'storyteller', github: 'avispatech/storyteller'`

If you are not on Rails, require the gem

`require 'storyteller'`

Create your User Story / Use Case class and extend from `Storyteller::Story`

Set your initial parameters `initialize_with :param1, :param2`

Define `validates_with`, `prepares_with` if necessary

Define your steps

    step :require_library
    step :define_initializer
    step :add_validation
    step :add_steps

And you are done! You can find more documentation in the Projects Github

This gem has been made with ❤️ by [AvispaTech](https://avispa.tech)
