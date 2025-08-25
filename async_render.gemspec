require_relative "lib/async_render/version"

Gem::Specification.new do |spec|
  spec.name        = "async_render"
  spec.version     = AsyncRender::VERSION
  spec.authors     = [ "Igor Kasyanchuk" ]
  spec.email       = [ "igorkasyanchuk@gmail.com" ]
  spec.homepage    = "https://github.com/igorkasyanchuk/async_render"
  spec.summary     = "Async render in Rails"
  spec.description = "Async render in Rails"
  spec.license     = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.required_ruby_version = ">= 3.0"
  spec.add_dependency "rails"
  spec.add_dependency "concurrent-ruby"
  spec.add_development_dependency "rspec-rails"
  spec.add_development_dependency "kaminari"
  spec.add_development_dependency "debug"
  spec.add_development_dependency "pg"
end
