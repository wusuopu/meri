#!/usr/bin/env ruby
#-*- coding:utf-8 -*-

require "parser"
require "runtime"

module MERI
  class Interpreter
    def initialize
      @parser = Parser.new
    end

    def eval code
      @parser.parser(code).eval(RootContext)
    end
  end
end
