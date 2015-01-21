#!/usr/bin/env ruby
#-*- coding:utf-8 -*-


$LOAD_PATH << '.'

require "test_helper"
require "lexer"

class LexerTest < Test::Unit::TestCase
  def test_identifier
    assert_equal [[:IDENTIFIER, "name"]], MERI::Lexer.new.tokenize('name')
  end

  def test_constant
    assert_equal [[:CONSTANT, "Name"]], MERI::Lexer.new.tokenize('Name')
  end

  def test_number
    assert_equal [[:NUMBER, 1]], MERI::Lexer.new.tokenize(" 1  ")
  end

  def test_string
    assert_equal [[:STRING, 'hi "hello"']], MERI::Lexer.new.tokenize(' "hi \"hello\"" ')
    assert_equal [[:STRING, "hi 'hello'"]], MERI::Lexer.new.tokenize(" 'hi \\'hello\\'' ")
  end

  def test_operator
    assert_equal [["+", "+"]], MERI::Lexer.new.tokenize(' + ')
    assert_equal [["||", "||"]], MERI::Lexer.new.tokenize('||')
    assert_equal [["->", "->"]], MERI::Lexer.new.tokenize('->')
  end
end
