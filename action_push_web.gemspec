require_relative "lib/action_push_web/version"

Gem::Specification.new do |spec|
  spec.name        = "action_push_web"
  spec.version     = ActionPushWeb::VERSION
  spec.authors     = [ "Chris Oliver" ]
  spec.email       = [ "excid3@gmail.com" ]
  spec.homepage    = "TODO"
  spec.summary     = "TODO: Summary of ActionPushWeb."
  spec.description = "TODO: Description of ActionPushWeb."
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 8.0.2.1"
  spec.add_dependency "base64", ">= 0.3.0"
  spec.add_dependency "jwt", "~> 3.0"
  spec.add_dependency "openssl", "~> 3.0"
  spec.add_dependency "net-http-persistent", ">= 4.0.0"
  spec.add_dependency "concurrent-ruby", ">= 1.3.0"
end
