# frozen_string_literal: true

AsyncRender.configure do |config|
  # Enable or disable parallel rendering
  # Default: true
  # config.enabled = true

  # Enable only in production for better performance
  # config.enabled = Rails.env.production?

  # Timeout for async operations in seconds
  # Default: 10
  # config.timeout = 10

  # Custom thread pool executor (optional)
  # By default, AsyncRender will create a thread pool sized based on your
  # database connection pool and RAILS_MAX_THREADS environment variable
  # config.executor = Concurrent::FixedThreadPool.new(10)

  # Custom state serialization for thread-local data (optional)
  # Use this to preserve Current attributes or other thread-local state
  # across async renders
  #
  # Example:
  # config.dump_state_proc = lambda do
  #   {
  #     current_user_id: Current.user&.id,
  #     request_id: Current.request_id,
  #     locale: I18n.locale
  #   }
  # end
  #
  # config.restore_state_proc = lambda do |state|
  #   Current.user = User.find_by(id: state[:current_user_id]) if state[:current_user_id]
  #   Current.request_id = state[:request_id]
  #   I18n.locale = state[:locale] if state[:locale]
  # end
end
