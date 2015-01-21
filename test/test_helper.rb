#!/usr/bin/env ruby
#-*- coding:utf-8 -*-

$LOAD_PATH << File.expand_path("../../src/", __FILE__)

require "test/unit"


class Test::Unit::TestCase
  def assert_include container, object
    assert container.include? object
  end
end
