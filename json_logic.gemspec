# frozen_string_literal: true

require_relative 'lib/json_logic/version'

Gem::Specification.new do |spec|
  spec.name = 'json_logic_ruby'
  spec.version = JsonLogic::VERSION
  spec.authors = ['Volodymyr Stashchenko', 'Andriy Savka']
  spec.email = %w[stashchenko@ukr.net savka.ai2015@gmail.com]

  spec.summary = 'Build complex rules, serialize them as JSON, and execute them in ruby.'
  spec.description = 'Build complex rules, serialize them as JSON, and execute them in ruby. See https://jsonlogic.com'
  spec.homepage = 'https://github.com/useful-libs/json_logic_ruby'

  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.2.0'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.glob('{lib}/**/*', File::FNM_DOTMATCH, base: __dir__)

  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport', '~> 7.0'

  spec.metadata['rubygems_mfa_required'] = 'true'
end
