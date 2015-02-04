#!/usr/bin/env ruby
#-*- coding:utf-8 -*-

module MERI
  class Context
    attr_reader :locals
    def initialize
      @locals = {}
    end
  end

  class BaseObject
    attr_accessor :ruby_value, :runtime_class
    def initialize runtime_class, ruby_value
      @runtime_class = runtime_class
      @ruby_value = ruby_value || self
    end
  end

  class MethodObject < BaseObject
    def initialize formal_params=[], body=nil
      @formal_params = formal_params
      @body = body
    end
    def call receiver, args
      return nil if !@body
    end
  end

  class ClassObject < BaseObject
    def new_with_value value
      BaseObject.new self, value
    end
  end

  # init the runtime enviroment
  Constants = {}                                      # the global constants
  RootContext = Context.new()                         # the top level context

  # built-in object
  Constants['TrueClass'] = ClassObject.new
  Constants['FalseClass'] = ClassObject.new
  Constants['NilClass'] = ClassObject.new
  Constants['Number'] = ClassObject.new
  Constants['String'] = ClassObject.new

  # built-in object
  Constants[true] = true
  Constants[false] = false
  Constants[nil] = nil

  # built-in method
  # TODO
  Constants['say'] = MethodObject.new

  Constants['ARGV'] = []
  ARGV.each do |v|
    Constants['ARGV'] << Constants['String'].new_with_value(v)
  end

end
