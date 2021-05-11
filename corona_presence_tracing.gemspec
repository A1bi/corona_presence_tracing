# frozen_string_literal: true

require_relative 'lib/corona_presence_tracing/version'

Gem::Specification.new do |s|
  s.name          = 'corona_presence_tracing'
  s.version       = CoronaPresenceTracing::VERSION
  s.authors       = ['Albrecht Oster']
  s.email         = ['albrecht@oster.online']

  s.summary       = 'Corona check-in link and QR code generator'
  s.description   = 'Implementation of the Corona Presence Tracing specification for check-in links and QR codes' \
                       'using Corona Contact Tracing apps.'
  s.homepage      = 'https://github.com/A1bi/corona_presence_tracing'
  s.license       = 'MIT'

  s.metadata = {
    'homepage_uri' => s.homepage,
    'source_code_uri' => s.homepage,
    'changelog_uri' => "#{s.homepage}/blob/master/CHANGELOG.md"
  }

  s.required_ruby_version = Gem::Requirement.new('>= 2.5.0')

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  s.files = `git ls-files -- lib/*`.split("\n")
  s.require_paths = ['lib']

  s.add_runtime_dependency 'google-protobuf', '~> 3.15'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec', '~> 3.10'
  s.add_development_dependency 'rubocop'
  s.add_development_dependency 'rubocop-rake'
  s.add_development_dependency 'rubocop-rspec'
  s.add_development_dependency 'simplecov'
end
