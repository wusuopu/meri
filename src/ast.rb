#!/usr/bin/env ruby
#-*- coding:utf-8 -*-

module MERI
  class Nodes < Struct.new(:nodes)
    def << node
      nodes << node
      self
    end
  end

  class LiteralNode < Struct.new(:value)
  end

  class NumberNode < LiteralNode
  end

  class StringNode < LiteralNode
  end

  class TrueNode < LiteralNode
    def initialize
      super(true)
    end
  end

  class FalseNode < LiteralNode
    def initialize
      super(false)
    end
  end

  class NilNode < LiteralNode
    def initialize
      super(nil)
    end
  end

  # Call function
  class CallNode < Struct.new(:receiver, :method, :arguments)
  end

  class WhileNode < Struct.new(:condition, :body)
  end

  class IfNode < Struct.new(:condition, :body, :else_body)
    def add_else else_body
      self['else_body'] = else_body
      self
    end
  end

  # ------------------------
  class ReturnNode < Struct.new(:value)
  end

  class CodeNode < Struct.new(:params, :body)
  end

  ASSIGN_TYPE_CONST = 1
  ASSIGN_TYPE_VAR   = 2

  class AssignNode < Struct.new(:name, :value)
    attr_reader :value_type
    def initialize name, value
      super(name, value)
      if name[0] == name[0].upcase
        @value_type = ASSIGN_TYPE_CONST
      else
        @value_type = ASSIGN_TYPE_VAR
      end
    end
  end

  class ValueNode < Struct.new(:name)
    attr_reader :value_type
    def initialize name
      super(name)
      if name[0] == name[0].upcase
        @value_type = ASSIGN_TYPE_CONST
      else
        @value_type = ASSIGN_TYPE_VAR
      end
    end
  end

  # TODO
  class ListNode
  end
end
