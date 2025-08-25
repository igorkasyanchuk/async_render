module AsyncRender
  class Engine < ::Rails::Engine
    isolate_namespace AsyncRender

    initializer "async_render.middleware" do |app|
      app.middleware.use AsyncRender::Middleware
    end

    initializer "async_render.helper" do
      ActiveSupport.on_load :action_view do
        include AsyncRender::AsyncHelper
        include AsyncRender::MemoizedHelper
      end
    end

    initializer "async_render.warmup" do
      ActiveSupport.on_load :action_controller do
        include AsyncRender::Warmup
        include AsyncRender::Controller
      end
    end
  end
end
