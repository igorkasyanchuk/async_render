require "active_support/concern"

module AsyncRender
  # Controller concern to set up per-request async rendering context
  module Controller
    extend ActiveSupport::Concern

    included do
      around_action :async_rendering
    end

    private

    def async_rendering
      # AsyncRender::Current.async_futures = Concurrent::Hash.new
      # AsyncRender::Current.warmup_partials = Concurrent::Hash.new
      yield
    end
  end
end
