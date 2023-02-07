# frozen_string_literal: true

require 'smart_init'
require 'active_support/all'
require_relative 'storyteller/version'

module Storyteller
  class Error < StandardError; end

  class Story
    extend SmartInit
    include ActiveSupport::Callbacks
    is_callable method_name: :execute
    attr_reader :errors

    define_callbacks :init, :validation, :preparation, :run, :verification

    set_callback(:init, :after) { @stage = :initialized }
    #
    # @note One callback at a time
    def self.after_init(arg = nil, &)
      return set_callback(:init, :after, &) if block_given?

      set_callback :init, :after, arg
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

    def self.validates_with(arg = nil, &block) = requisite(arg, block)

    set_callback(:preparation, :after) { @stage = :prepared }

    #
    # @note One callback at a time
    def self.prepare(arg = nil, &)
      if block_given?
        set_callback(:preparation, :before, &)
      else
        set_callback :preparation, :before, arg
      end
    end

    class << self
      alias prepares_with prepare
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
      return set_callback(:run, :after, &) if block_given?

      set_callback :run, :after, arg
    end

    def self.verify(arg, &)
      return set_callback(:verification, :before, &) if block_given?

      Array.wrap(arg).each do |callback|
        set_callback :verification, :before, callback
      end
    end

    def self.done_criteria(arg = nil, &block) = verify(arg, block)

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

    def execute
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

      self
    end
  end
end
