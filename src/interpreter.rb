#!/usr/bin/env ruby
#-*- coding:utf-8 -*-

require "parser"
require "runtime"
require "exception"

module MERI
  class Interpreter
    def initialize
      @parser = Parser.new
    end

    def eval code
      nodes = @parser.parse(code)
      nodes.eval(RootContext)
    end
  end

  class Nodes
    def eval context
      return_value = nil
      nodes.each do |node|
        return_value = node.eval context
      end
      return_value || Constants['nil']
    end
  end

  # Literal eval
  class NumberNode
    def eval context
      Constants['Number'].new_with_value value
    end
  end
  class StringNode
    def eval context
      Constants['String'].new_with_value value
    end
  end
  class TrueNode
    def eval context
      Constants['true']
    end
  end
  class FalseNode
    def eval context
      Constants['false']
    end
  end
  class NilNode
    def eval context
      Constants['nil']
    end
  end
  # Assign a variable / constant
  class AssignNode
    def eval context
      if @value_type == ASSIGN_TYPE_CONST && context.locals[name]
        raise "already initialized constant #{name}"
      end
      context.locals[name] = value.eval(context)
    end
  end
  class ValueNode
    def eval context
      context.locals[name]
    end
  end

  class CallNode
    def eval context
      local_context = context.clone
      evaluated_arguments = arguments.map {|arg|
        arg.eval(local_context)
      }
      if receiver
        value = receiver.eval(local_context)
        if !value
          raise "undefined '#{receiver.name}'"
        end
        value.call method, evaluated_arguments
      else
        value = local_context.current_self
        local_method = method.eval(local_context)
        raise "Method not found: #{method.name}" if local_method.nil?
        raise "#{method.name} is not callable" if ![MethodObject, Proc].include?(local_method.class)
        local_method.call value, evaluated_arguments
      end
    end
  end

  class CodeNode
    def eval context
      MethodObject.new params, body, context
    end
  end

  class IfNode
    def eval context
      if condition.eval(context).ruby_value
        body.eval context
      elsif else_body
        else_body.eval context
      else
        Constants['nil']
      end
    end
  end

  class WhileNode
    def eval context
      while condition.eval(context).ruby_value
        begin
          body.eval context
        rescue BreakLoopException
          break
        rescue NextLoopException
          next
        end
      end
    end
  end

  class BreakLoopNode
    def eval context
      raise BreakLoopException.new
    end
  end

  class NextLoopNode
    def eval context
      raise NextLoopException.new
    end
  end

  class ListNode
    def eval context
      result = Constants['List'].new_with_value []
      value.each do |v|
        result << v.eval(context)
      end
      result
    end
  end

  class HashNode
    def eval context
      result = Constants['Hash'].new_with_value({})
      value.each do |k, v|
        k = k.eval(context)
        v = v.eval(context)
        result.ruby_value[k.ruby_value] = v
        result.hash_key[k.ruby_value] = k
      end
      result
    end
  end
end
