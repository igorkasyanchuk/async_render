# frozen_string_literal: true

# lib/async_render/middleware.rb
require "concurrent"
require "securerandom"

module AsyncRender
  class Middleware
    HTML_TYPE = %r{\Atext/html}.freeze
    PATTERN_PREFIX = "<!--ASYNC-PLACEHOLDER:".freeze
    PATTERN_REGEXP = /<!--ASYNC-PLACEHOLDER:([0-9a-z\.\/]+)-->/.freeze

    def initialize(app)
      @app = app
    end

    # def benchmark
    #   Benchmark.bm(100) do |x|
    #     html = ("hello" * 10000) + "hello<!--ASYNC-PLACEHOLDER:123-->World" + ("hello" * 10000)
    #     token_to_fragment = { "123" => "Hello" }

    #     x.report("replace") do
    #       1000.times do
    #         html1 = html.dup

    #         html1.gsub!(PATTERN_REGEXP) do |match|
    #           token = Regexp.last_match(1)
    #           token_to_fragment.fetch(token, "")
    #         end

    #         # puts 1
    #         # puts html1
    #       end
    #     end

    #     token_to_fragment_2 = { "<!--ASYNC-PLACEHOLDER:123-->" => "Hello" }

    #     x.report("each") do
    #       1000.times do
    #         html2 = html.dup

    #         token_to_fragment.each do |token, fragment|
    #           html2[token] = fragment
    #         end

    #         # puts 2
    #         # puts html2
    #       end
    #     end
    #   end
    # end

    def call(env)
      status, headers, body = @app.call(env)

      return [ status, headers, body ] if skip?

      if html?(headers)
        html = +""
        begin
          body.each { |part| html << part }
        ensure
          body.close if body.respond_to?(:close)
        end

        return [ status, headers, [ html ] ] if !html.include?(PATTERN_PREFIX)

        # Wait with timeout and collect fragments
        token_to_fragment = {}
        futures_hash = AsyncRender::Current.async_futures

        if futures_hash.any?
          # Create array of [token, future] pairs to maintain association
          futures_array = futures_hash.to_a

          # Wait for all futures to complete with timeout
          all_futures = Concurrent::Promises.zip(*futures_array.map(&:last))
          all_futures.wait(AsyncRender.timeout)

          # Collect results - check each future individually
          futures_array.each do |token, future|
            token_to_fragment[token] = future.fulfilled? ? future.value : ""
          end
        end

        # token_to_fragment.each do |token, fragment|
        #   Rails.logger.info { "[AsyncRender] Replacing: #{token}" } if Rails.env.local?
        #   html[token] = fragment
        # end

        # Single-pass replacement using regex
        html.gsub!(PATTERN_REGEXP) do |match|
          token = Regexp.last_match(1)
          Rails.logger.info { "[AsyncRender] Replacing: #{token}" } if Rails.env.local?
          token_to_fragment.fetch(token, "")
        end

        AsyncRender::Current.async_futures.clear
        AsyncRender::Current.warmup_partials.clear

        headers["Content-Length"] = html.bytesize.to_s if headers["Content-Length"]
        [ status, headers, [ html ] ]
      else
        [ status, headers, body ]
      end
    end

    private

    def skip?
      AsyncRender::Current.skip_middleware || !AsyncRender.enabled
    end

    def html?(headers)
      headers["Content-Type"]&.match?(HTML_TYPE)
    end

    def wait_or_empty(future, timeout = AsyncRender.timeout)
      future.wait(timeout)
      future.fulfilled? ? future.value : ""
    end
  end
end
