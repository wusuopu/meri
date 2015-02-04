#!/usr/bin/env ruby
#-*- coding:utf-8 -*-

module MERI
  class Context
    attr_reader :locals, :current_self, :current_class
    def initialize current_self, current_class=nil
      @locals = {}
      @current_self = current_self
      @current_class = current_class || current_self.runtime_class
    end
  end

  class BaseObject
    attr_accessor :ruby_value, :runtime_class, :runtime_class_name
    def initialize runtime_class, ruby_value=nil
      @runtime_class = runtime_class
      @runtime_class_name = runtime_class.name
      @ruby_value = ruby_value || self
    end
    def call method, args=[]
      @runtime_class.lookup(method).call(self, args)
    end
  end

  class MethodObject < BaseObject
    def initialize formal_params=[], body=nil
      @formal_params = formal_params
      @body = body
    end
    def call receiver, args
      return nil if !@body
      context = Context.new receiver
      @formal_params.each_with_index do |param, index|
        context.locals[param] = args[index]
      end
      @body.eval context
    end
  end

  class ClassObject < BaseObject
    attr_reader :runtime_methods, :name
    def initialize name='Class'
      @name = name
      @runtime_methods = {}
      @runtime_class = Constants['Class']
    end

    def lookup method_name
      method = @runtime_methods[method_name]
      raise "Method not found: #{method_name}" if method.nil?
      method
    end

    def define_method name, &block
      @runtime_methods[name.to_s] = block
    end

    def new
      BaseObject.new self
    end

    def new_with_value value
      BaseObject.new self, value
    end
  end

  # init the runtime enviroment
  Constants = {}                             # the global constants

  # built-in object
  Constants['TrueClass'] = ClassObject.new 'TrueClass'
  Constants['FalseClass'] = ClassObject.new 'FalseClass'
  Constants['NilClass'] = ClassObject.new 'NilClass'
  Constants['Number'] = ClassObject.new 'Number'
  Constants['String'] = ClassObject.new 'String'
  Constants['Object'] = ClassObject.new 'Object'

  RootSelf = Constants['Object'].new
  RootContext = Context.new(RootSelf)        # the top level context


  # built-in object
  Constants[true] = Constants['TrueClass'].new_with_value(true)
  Constants[false] = Constants['FalseClass'].new_with_value(false)
  Constants[nil] = Constants['NilClass'].new_with_value(nil)

  # built-in method
  # TODO
  #Constants['say'] = MethodObject.new
  RootContext.locals['say'] = Proc.new{|receiver, args|
    args.each do |arg|
      print(arg.ruby_value, " ")
    end
    print("\n")
  }

  ['+', '-', '*', '/', '%', '**'].each do |method|
    Constants['Number'].define_method method do |receiver, args|
      result = receiver.ruby_value.send method, args[0].ruby_value
      Constants['Number'].new_with_value(result)
    end
  end
  #Constants['ARGV'] = []
  #ARGV.each do |v|
    #Constants['ARGV'] << Constants['String'].new_with_value(v)
  #end

end
