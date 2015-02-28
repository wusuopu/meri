#!/usr/bin/env ruby
#-*- coding:utf-8 -*-

$LOAD_PATH << File.expand_path("..", __FILE__)

require "test_helper"
require "interpreter"

include MERI

class InterpreterTest < Test::Unit::TestCase
  def test_true
    assert_equal true, Interpreter.new.eval("true").ruby_value
  end
  def test_string
    assert_equal '123', Interpreter.new.eval("'123'").ruby_value
  end
  def test_if_block
    code = <<EOF
if true
  "Ok!"
end
EOF
    assert_equal "Ok!", Interpreter.new.eval(code).ruby_value
  end
  def test_invocation
    code = <<EOF
fun1 = (a, b)->
  a + b
end
fun1 1, 2
EOF
    assert_equal 3, Interpreter.new.eval(code).ruby_value
  end
  def test_pipeinvocation
    code = <<EOF
add1 = (a)->
  a + 1
end
mul2 = (a)->
  a * 2
end
power2 = (a)->
  a ** 2
end
add1(1) |> mul2 |> power2
EOF
    assert_equal 16, Interpreter.new.eval(code).ruby_value
  end
end
