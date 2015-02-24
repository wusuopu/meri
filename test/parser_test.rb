#!/usr/bin/env ruby
#-*- coding:utf-8 -*-


$LOAD_PATH << File.expand_path("..", __FILE__)

require "test_helper"
require "parser"

include MERI

class ParserTest < Test::Unit::TestCase
  def test_literal
    # test number
    assert_equal Nodes.new([NumberNode.new(1.1)]), Parser.new.parse(' 1.1 ')
    # test_string
    assert_equal Nodes.new([StringNode.new('test')]), Parser.new.parse(' "test" ')

    assert_equal Nodes.new([TrueNode.new()]), Parser.new.parse(' true ')
    assert_equal Nodes.new([FalseNode.new()]), Parser.new.parse(' false ')
    assert_equal Nodes.new([NilNode.new()]), Parser.new.parse(' nil ')
    assert_equal Nodes.new([ListNode.new([NumberNode.new(1), NumberNode.new(2)])]), Parser.new.parse(' [1, 2] ')
    assert_equal Nodes.new([HashNode.new({StringNode.new("a") => NumberNode.new(1), StringNode.new("b") => NumberNode.new(2)})]), Parser.new.parse(' {"a": 1, "b": 2} ')
  end

  def test_operation
    assert_equal Nodes.new([
      CallNode.new(NumberNode.new(1.0), '+', [
        CallNode.new(NumberNode.new(2.0), '*', [NumberNode.new(3.0)])
      ])
    ]), Parser.new.parse(' 1 + 2 * 3 ')
    assert_equal Nodes.new([CallNode.new(NumberNode.new(1.0), '-', [NumberNode.new(2.0)])]), Parser.new.parse(' 1 - 2 ')
    assert_equal Nodes.new([CallNode.new(NumberNode.new(1.0), '*', [NumberNode.new(2.0)])]), Parser.new.parse(' 1 * 2 ')
    assert_equal Nodes.new([CallNode.new(NumberNode.new(1.0), '/', [NumberNode.new(2.0)])]), Parser.new.parse(' 1 / 2 ')

    assert_equal Nodes.new([CallNode.new(
      NumberNode.new(1.0), '+', [CallNode.new(NumberNode.new(2.0), '*', [NumberNode.new(3.0)])]
    )]), Parser.new.parse(' 1 + 2 * 3 ')

    assert_equal Nodes.new([CallNode.new(
      NumberNode.new(1.0), '+', [CallNode.new(NumberNode.new(2.0), '!', [])]
    )]), Parser.new.parse(' 1 + !2 ')
  end

  def test_assign
    assert_equal Nodes.new([AssignNode.new('var1', StringNode.new('hello'))]), Parser.new.parse('var1 = "hello"')
    assert_equal Nodes.new([AssignNode.new('var1', StringNode.new('hello'))]), Parser.new.parse("var1 = \n'hello'")
    assert_equal Nodes.new([AssignNode.new('var1', StringNode.new('hello'))]), Parser.new.parse("var1 = { 'hello' }")
    assert_equal Nodes.new([AssignNode.new('Const', StringNode.new('hello'))]), Parser.new.parse('Const = "hello"')
  end

  def test_if
code = <<EOF
if(a > b && ( a > c ))
1
elif b > c
2
else
3
end
EOF
    assert_equal Nodes.new([
      IfNode.new(
        CallNode.new(
          CallNode.new(ValueNode.new('a'), '>', [ValueNode.new('b')]),
          '&&', [CallNode.new(
            ValueNode.new('a'), '>', [ValueNode.new('c')]
          )]
        ), Nodes.new([NumberNode.new(1.0)]),
        IfNode.new(
          CallNode.new(ValueNode.new('b'), '>', [ValueNode.new('c')]),
          Nodes.new([NumberNode.new(2.0)]),
          Nodes.new([NumberNode.new(3.0)])
        )
      )
    ]), Parser.new.parse(code)
  end

  def test_function
code = <<EOF
a = (a, b) ->
  a + b
end
EOF
    assert_equal Nodes.new([
      AssignNode.new('a', CodeNode.new(['a', 'b'], Nodes.new([
        CallNode.new(ValueNode.new('a'), '+', [ValueNode.new('b')])
      ])))
    ]), Parser.new.parse(code)
  end

  def test_while
code = <<EOF
while (a > b)
1
end
EOF
    assert_equal Nodes.new([
      WhileNode.new(
        CallNode.new(ValueNode.new('a'), '>', [ValueNode.new('b')]),
        Nodes.new([NumberNode.new(1.0)])
      )]), Parser.new.parse(code)
  end

  def test_invocation
code = <<EOF
say(a,  b)
EOF
    assert_equal Nodes.new([
      CallNode.new(nil, ValueNode.new('say'), [ValueNode.new('a'), ValueNode.new('b')])
      ]), Parser.new.parse(code)
  end
end
