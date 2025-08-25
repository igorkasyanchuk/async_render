require "bundler/setup"
require "rails"
require "action_controller/railtie"
require "action_view/railtie"
require "rspec/rails"
require "async_render"

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
  config.use_transactional_fixtures = false
end
