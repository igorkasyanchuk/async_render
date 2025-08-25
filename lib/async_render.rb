# frozen_string_literal: true

require "async_render/version"
require "async_render/controller"
require "async_render/engine"
require "async_render/middleware"
require "async_render/current"
require "async_render/utils"
require "concurrent"

module AsyncRender
  PLACEHOLDER_PREFIX = "<!--ASYNC-PLACEHOLDER:".freeze
  PLACEHOLDER_SUFFIX = "-->".freeze
  PLACEHOLDER_TEMPLATE = "#{PLACEHOLDER_PREFIX}%s#{PLACEHOLDER_SUFFIX}".freeze

  mattr_accessor :enabled
  mattr_accessor :timeout
  mattr_accessor :executor
  mattr_accessor :dump_state_proc
  mattr_accessor :restore_state_proc

  @@enabled = true
  @@timeout = 10
  @@executor = nil
  @@dump_state_proc = nil
  @@restore_state_proc = nil

  def self.configure
    yield self
  end

  # Lazily build a conservative default executor sized to avoid DB pool contention.
  def self.executor
    @@executor ||= build_default_executor
  end

  # Global, process-local memoized cache for rendered fragments or values
  # NOTE: This persists across requests in the Ruby process
  def self.memoized_cache
    @memoized_cache ||= Concurrent::Map.new
  end

  def self.reset_memoized_cache!
    @memoized_cache = Concurrent::Map.new
  end

  def self.build_default_executor
    # Heuristics: cap by AR pool size and RAILS_MAX_THREADS, with a sane upper bound.
    ar_pool_size = begin
      defined?(ActiveRecord) && ActiveRecord::Base.connection_pool&.size
    rescue StandardError
      nil
    end

    puma_max_threads = Integer(ENV["RAILS_MAX_THREADS"]) rescue nil

    # Defaults
    hard_cap = 16
    max_threads = [ ar_pool_size, puma_max_threads, hard_cap ].compact.min || 8
    min_threads = [ 2, max_threads ].min

    # Concurrent::ThreadPoolExecutor.new(
    #   min_threads: min_threads,
    #   max_threads: max_threads,
    #   idletime: 60,
    #   max_queue: 1_000,
    #   fallback_policy: :caller_runs
    # )
    #
    Concurrent::FixedThreadPool.new(
      max_threads,
      idletime: 60,
      max_queue: 1_000,
      fallback_policy: :caller_runs
    )
    #
    # Concurrent::CachedThreadPool.new(
    #   min_threads: min_threads,
    #   max_threads: max_threads,
    #   max_queue: 1_000,
    #   fallback_policy: :caller_runs
    # )
  end
end

require "async_render/executor"
require "async_render/warmup"
require "async_render/async_helper"
require "async_render/memoized_helper"
