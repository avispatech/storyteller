# frozen_string_literal: true
require "smart_init"
require "active_support/all"
require_relative "storyteller/version"

module Storyteller
  class Error < StandardError; end

  class Story
    extend SmartInit
    is_callable method_name: :execute
    include ActiveSupport::Callbacks

    define_callbacks :init, :validation, :preparation, :run

    set_callback :init, :after do
      @stage = :initialized
    end
    #
    # @note One callback at a time
    def self.after_init(arg=nil)
      if block_given?
        set_callback :init, :after do
          yield
        end
      else
        set_callback :init, :after, arg
      end
    end

    #
    # @note One callback at a time
    def self.validates_with(arg=nil, &block)
      if block_given?
        set_callback :validation, :before, -> () { block.call }
      else
        set_callback :validation, :before, arg
      end
    end

    set_callback :preparation, :after do 
      @stage = :prepared
    end

    #
    # @note One callback at a time
    def self.prepares_with(arg=nil)
      if block_given?
        set_callback :preparation, :before do
          yield
        end
      else
        set_callback :preparation, :before, arg
      end
    end

    #
    # @note One callback at a time
    def self.step(arg=nil)
      if block_given?
        set_callback :run, :before do
          yield
        end
      else
        set_callback :run, :before, arg
      end
    end

    #
    # @note One callback at a time
    def self.after_run(arg)
      if block_given?
        set_callback :run, :after do
          yield
        end
      else
        set_callback :run, :after, arg
      end
    end

    def success?
      @errors.empty?
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

    def prepared? = @stage != :initializing && @stage != :prepared

    def execute
      @stage ||= :initializing
      @result = nil
      @errors = []
  
      run_callbacks :init unless initialized?
      run_callbacks :preparation unless prepared?

      #internal_validate
      return self unless valid?
  
      run_callbacks :run 
      return self unless success?
  
      self
    end
  end
  
end

