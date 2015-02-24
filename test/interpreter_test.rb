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
end
