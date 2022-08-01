# frozen_string_literal: true
require "smart_init"
require_relative "storyteller/version"

module Storyteller
  class Error < StandardError; end
  
  class Story
    extend SmartInit
    is_callable method_name: :execute

    @@after_init_methods = []
    @@prepare_method = :auto_approve
    @@validate_method = :auto_approve
    @@step_methods = []

    def valid?
      @errors = []
      send @@validate_method

      @errors.empty?
    end

    def execute
      @result = nil
      @@after_init_methods.each do |meth|
        if meth.is_a? Proc
          meth.call
        else
          send(meth)
        end
      end

      send @@prepare_method
      send @@validate_method

      return self unless valid?

      @@step_methods.each do |step|
        meth = step[:arg]
        if meth.is_a?(Proc)
          @result = self.instance_eval &meth
        else
          @result = send(meth)
        end
      end

      return self unless valid?

      self
    end

    def result
      @result
    end

    def self.after_init(meth = nil, &block)
      @@after_init_methods << (meth.nil? ? block : meth)
    end

    def self.step(name = '', meth = nil, &block)
      @@step_methods << { name:, arg: (meth.nil? ? block : meth) }
    end

    def self.prepares_with(method_symbol)
      @@prepare_method = method_symbol
    end

    def self.validates_wtih(method_symbol)
      @@validate_method = method_symbol
    end

    def evaluate(&block)
      @self_before_instance_eval = eval 'self', block.binding
      instance_eval &block
    end
    
    def method_missing(method, *args, &block)
      @self_before_instance_eval.send method, *args, &block
    end

    def steps
      @@step_methods.map { |step| step[:name] }
    end

    def auto_approve = true
  end
end
