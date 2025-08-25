require "concurrent-ruby"

module AsyncRender
  class Current < ActiveSupport::CurrentAttributes
    attribute :skip_middleware, default: true
    attribute :async_futures, default: Concurrent::Hash.new
    attribute :warmup_partials, default: Concurrent::Hash.new
  end
end
