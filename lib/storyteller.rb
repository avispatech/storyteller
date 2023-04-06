# frozen_string_literal: true

require 'smart_init'
require 'active_support/all'
require_relative 'storyteller/version'
require_relative 'storyteller/logger'

module Storyteller
  LOGGER = CustomLogger.new

  class Error < StandardError; end

  class Story
    extend SmartInit

    def self.initialize_with(*params, **harams)
      new_harams = harams.merge({ silent_story: false })
      super(*params, **new_harams)
    end

    is_callable method_name: :execute
    include ActiveSupport::Callbacks
    attr_reader :errors, :result

    define_callbacks :init, :validation, :preparation, :run, :after_run, :verification

    set_callback :init, :after do
      @stage = :initialized
    end
    #
    # @note One callback at a time
    def self.after_init(arg = nil, &)
      if block_given?
        set_callback(:init, :after, &)
      else
        set_callback :init, :after, arg
      end
    end

    #
    # @note One callback at a time
    def self.requisite(arg = nil, &block)
      if block_given?
        set_callback :validation, :before, -> { block.call }
      else
        Array.wrap(arg).each do |callback|
          set_callback :validation, :before, callback
        end
      end
    end

    def self.validates_with(arg = nil, &block)
      requisite(arg, block)
    end

    set_callback :preparation, :after do
      @stage = :prepared
    end

    #
    # @note One callback at a time
    def self.prepare(arg = nil, &)
      if block_given?
        set_callback(:preparation, :before, &)
      else
        set_callback :preparation, :before, arg
      end
    end

    def self.prepares_with(arg = nil, &block)
      prepare(arg, block)
    end

    #
    # @note One callback at a time
    def self.step(arg = nil, &)
      if block_given?
        set_callback(:run, :before, &)
      else
        set_callback :run, :before, arg
      end
    end

    #
    # @note One callback at a time
    def self.check(args = [], &)
      if block_given?
        set_callback(:run, :before, &)
      else
        args.each do |arg|
          set_callback :run, :before, arg
        end
      end
    end

    #
    # @note One callback at a time
    def self.after_run(arg, &)
      if block_given?
        set_callback(:after_run, :after, &)
      else
        set_callback :after_run, :after, arg
      end
    end

    def self.verify(arg, &)
      if block_given?
        set_callback(:verification, :before, &)
      else
        Array.wrap(arg).each do |callback|
          set_callback :verification, :before, callback
        end
      end
    end

    def self.done_criteria(arg = nil, &block)
      verify(arg, block)
    end

    def success?
      return true if @stage == :success

      @stage == :executed && @errors.empty?
    end

    def valid?
      @errors = []
      error(:steps, :empty) if __callbacks[:run].empty?
      run_callbacks :validation
      @errors.empty?
    end

    def error(element, kind)
      @errors << { element:, kind: }
    end

    def initialized? = @stage != :initializing

    def prepared? = %i[initializing initialized prepared].exclude? @stage

    def execute # rubocop:disable Metrics/CyclomaticComplexity, Metrics/MethodLength
      @stage ||= :initializing
      @result = nil
      @errors = []

      run_callbacks :init unless initialized?
      run_callbacks :preparation unless prepared?

      return self unless valid?

      @errors = []
      run_callbacks :run
      @stage = :executed
      run_callbacks :verification if errors.empty?
      return self unless success?

      log_execution_if_silent_mode
      run_callbacks :after_run unless @silent_story

      self
    end

    def log_execution_if_silent_mode
      return unless @silent_story

      LOGGER.warn "Story #{self.class.name} has been executed with silent mode"
    end
  end
end
