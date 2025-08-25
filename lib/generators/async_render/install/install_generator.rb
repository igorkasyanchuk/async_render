module AsyncRender
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      desc "Creates an AsyncRender initializer file"

      def copy_initializer
        template "async_render.rb", "config/initializers/async_render.rb"
      end

      def show_readme
        readme "README" if behavior == :invoke
      end
    end
  end
end
