#!/usr/bin/env ruby
#-*- coding:utf-8 -*-


$LOAD_PATH << File.expand_path("..", __FILE__)

require "test_helper"
require "parser"

include MERI

class ParserTest < Test::Unit::TestCase
  def test_number
    assert_equal Nodes.new([NumberNode.new(1.1)]), Parser.new.parse(' 1.1 ')
  end

  def test_string
    assert_equal Nodes.new([StringNode.new('test')]), Parser.new.parse(' "test" ')
  end

  def test_assign
    assert_equal Nodes.new([VariableAssignNode.new('var1', StringNode.new('hello'))]), Parser.new.parse('var1 = "hello"')
    assert_equal Nodes.new([ConstantAssignNode.new('Const1', StringNode.new('hello'))]), Parser.new.parse('Const1 = "hello"')
  end

  def test_function
code = <<EOF
def fun1(a, b){
  1
}
EOF
    assert_equal Nodes.new([FunctionNode.new('fun1', ['a', 'b'], Nodes.new(NumberNode.new(1)))]), Parser.new.parse(code)
  end
end
