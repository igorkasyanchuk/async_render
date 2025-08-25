module AsyncRender
  class Executor
    def initialize(partial:, locals:, state:, formats: [ :html ])
      @partial = partial
      @locals = locals
      @state = state
      @formats = formats
    end

    def call
      # Wrap in Rails executor for proper request-local state
      Rails.application.executor.wrap do
        # Ensure we have a database connection for this thread
        begin
          AsyncRender.restore_state_proc&.call(state)
          ApplicationController.renderer.render(partial:, locals:, formats:)
        rescue => e
          Rails.logger.error { "Error rendering #{partial}: #{e.message}" }
          e.backtrace.each { |line| Rails.logger.error { "  #{line}" } }

          if Rails.env.local?
            <<~HTML
              <p style='background-color:red;color:white'>
                Error rendering #{ERB::Util.html_escape(partial)}: #{ERB::Util.html_escape(e.message)}<br>
                #{ERB::Util.html_escape(e.backtrace.join("\n")).gsub("\n", "<br>")}
              </p>
            HTML
          else
            ""
          end
        end
      end
    end

    private

    attr_reader :partial, :locals, :context, :state, :formats
  end
end
