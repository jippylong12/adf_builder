# frozen_string_literal: true

require_relative "lib/adf_builder/version"

Gem::Specification.new do |spec|
  spec.name          = "adf_builder"
  spec.version       = AdfBuilder::VERSION
  spec.authors       = ["marcus.salinas"]
  spec.email         = ["12.marcus.salinas@gmail.com"]

  spec.summary       = "Create XML for the Auto-base Date Format"
  spec.description   = "Easily create XML in ADF format to send by email."
  spec.homepage      = "https://github.com/jippylong12/adf_builder"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 2.4.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/jippylong12/adf_builder"
  spec.metadata["changelog_uri"] = "https://github.com/jippylong12/adf_builder/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "ox", "~> 2.14"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
