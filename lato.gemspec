require_relative "lib/lato/version"

Gem::Specification.new do |spec|
  spec.name        = "lato"
  spec.version     = Lato::VERSION
  spec.authors     = ["Gregorio Galante"]
  spec.email       = ["me@gregoriogalante.com"]
  spec.homepage    = "https://github.com/GAMS-Software/lato"
  spec.summary     = "Basic engine for all Lato projects"
  spec.description = "A Rails engine that includes what you need to build a new project!"
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/GAMS-Software/lato"
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 7.0.4"
  spec.add_dependency "rails-i18n"
  spec.add_dependency "bcrypt"
  spec.add_dependency "bootstrap"
  spec.add_dependency "kaminari"
  spec.add_dependency "browser"
  spec.add_dependency "eth"
end
