# frozen_string_literal: true

module AsyncRender
  module AsyncHelper
    include AsyncRender::Utils

    POOL = AsyncRender.executor

    def async_render(partial, locals = {})
      return render(partial, locals) unless AsyncRender.enabled

      AsyncRender::Current.skip_middleware = false

      warmup_key = build_memoized_render_key(partial, locals)
      placeholder = AsyncRender::Current.warmup_partials[warmup_key]
      return placeholder if placeholder

      token       = generate_token(partial)
      placeholder = (AsyncRender::PLACEHOLDER_TEMPLATE % token).html_safe
      state       = AsyncRender.dump_state_proc&.call

      AsyncRender::Current.async_futures[token] = Concurrent::Promises.future_on(POOL) do
        AsyncRender::Executor.new(partial:, locals:, state:).call
      end

      placeholder
    end
  end
end
