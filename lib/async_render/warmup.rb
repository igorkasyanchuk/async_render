require "active_support/concern"

module AsyncRender
  module Warmup
    extend ActiveSupport::Concern

    include AsyncRender::Utils

    POOL = AsyncRender.executor

    class_methods do
      # Usage:
      #   warmups only: [:show] do
      #     warmup_render('users/menu', user: current_user)
      #     warmup_render('users/sidebar')
      #   end
      def warmups(**filters, &block)
        before_action(**filters) do
          instance_exec(&block) if block
        end
      end

      # Backwards compatibility with earlier name
      alias_method :warmup_render_before_action, :warmups
    end

    # Queue an async render for a partial so views can reference it via placeholders.
    # The result is stitched into the HTML by the middleware.
    def warmup_render(partial, locals = {})
      return unless AsyncRender.enabled

      AsyncRender::Current.skip_middleware = false

      warmup_key = build_memoized_render_key(partial, locals)
      placeholder = AsyncRender::Current.warmup_partials[warmup_key]
      return placeholder if placeholder

      token       = generate_token(partial)
      placeholder = (AsyncRender::PLACEHOLDER_TEMPLATE % token).html_safe
      state       = AsyncRender.dump_state_proc&.call
      AsyncRender::Current.warmup_partials[warmup_key] = placeholder

      AsyncRender::Current.async_futures[token] = Concurrent::Promises.future_on(POOL) do
        AsyncRender::Executor.new(partial:, locals:, state:).call
      end

      placeholder
    end
  end
end
