#!/usr/bin/env ruby
#-*- coding:utf-8 -*-

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

class FunctionCallNode < Struct.new(:receiver, :method, :arguments)
end

class ConstantNode < Struct.new(:name)
end

class ConstantAssignNode < Struct.new(:name, :value)
end

class VariableNode < Struct.new(:name)
end

class VariableAssignNode < Struct.new(:name, :value)
end

class FunctionNode < Struct.new(:name, :params, :body)
end

class WhileNode < Struct.new(:condition, :body)
end

class IfNode < Struct.new(:condition, :body)
end
