# frozen_string_literal: true

require_relative "lib/transport/version"

Gem::Specification.new do |spec|
  spec.name = "transport"
  spec.version = Transport::VERSION
  spec.authors = ["Leonardo Luarte G."]
  spec.email = ["leonardo@luarte.net"]

  spec.summary = "Wraps Typhoeus for a simpler approach to HTTP requests"
  spec.description = "Wraps Typhoeus for a simpler approach to HTTP requests"
  spec.homepage = "https://github.com/avispatech/transport"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/avispatech/transport"
  spec.metadata["changelog_uri"] = "https://github.com/avispatech/transport"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"
  spec.add_dependency "oj" 
  spec.add_dependency "typhoeus", "~>1.4"
  spec.add_dependency "hashie", "~>5.0"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
