#!/usr/bin/env ruby
#-*- coding:utf-8 -*-


$LOAD_PATH << File.expand_path("..", __FILE__)

require "test_helper"
require "runtime"

include MERI

class RuntimeTest < Test::Unit::TestCase
  def test_create_an_object
    assert_equal Constants["Object"], Constants["Object"].new.runtime_class
  end

  def test_create_object_value
    assert_equal 11, Constants["Number"].new_with_value(11).ruby_value
  end

  def test_lookup_method
    assert_not_nil Constants["Number"].lookup("**")
    assert_raise(RuntimeError) { Constants["Object"].lookup("non-existant") }
  end

  def test_call_method
    result = Constants["Number"].new_with_value(11).call('**', [Constants["Number"].new_with_value(2)])
    assert_equal 11**2, result.ruby_value
  end

  def test_a_class_is_a_class
    assert_equal Constants["Class"], Constants["Number"].runtime_class
  end
end
