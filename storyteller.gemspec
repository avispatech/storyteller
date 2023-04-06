# frozen_string_literal: true

require_relative 'lib/storyteller/version'

Gem::Specification.new do |spec|
  spec.name = 'storyteller'
  spec.version = Storyteller::VERSION
  spec.authors = ['Leonardo Luarte G']
  spec.email = ['leonardo@luarte.net']

  spec.summary = 'Run user stories based on a simple DSL'
  spec.description = 'User stories or Use Cases can be written in a procedural way,
                        like a recipe, to increase the understanding of the problem'
  spec.homepage = 'https://blog.avispa.tech/storyteller/'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.1.0'

  # spec.metadata['allowed_push_host'] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/avispatech/storyteller'
  spec.metadata['changelog_uri'] = 'https://github.com/avispatech/storyteller/changelog'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"
  spec.add_dependency 'activesupport'
  spec.add_dependency 'smart_init'

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
  # Bundler.require(:default, :development)
  spec.metadata['rubygems_mfa_required'] = 'true'
end
