#!/usr/bin/env ruby
#-*- coding:utf-8 -*-


$LOAD_PATH << File.expand_path("..", __FILE__)

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
    assert_equal [[:NUMBER, -1.0]], MERI::Lexer.new.tokenize(" -1  ")
    assert_equal [[:NUMBER, 1e2]], MERI::Lexer.new.tokenize(" 1e2")
    assert_equal [[:NUMBER, 1E-2]], MERI::Lexer.new.tokenize(" 1e-2")
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

  def test_comment
    assert_equal [[:NUMBER, 1], [:NEWLINE, "\n"], [:STRING, 'hello']], MERI::Lexer.new.tokenize("1 ; this is comments\n'hello'")
  end

  def test_block
    code = "()->\nend"
    assert_equal [["(", "("], [")", ")"], ["->", "->"], [:BLOCK_BEGIN, "\n"], [:BLOCK_END, "end"]], MERI::Lexer.new.tokenize(code)

    code = "if (a > b && a > c\n\t|| a > d)\nelse\nend"
    assert_equal [
      [:IF, "if"], ["(", "("], [:IDENTIFIER, "a"],
      [">", ">"], [:IDENTIFIER, "b"], ["&&", "&&"],
      [:IDENTIFIER, "a"], [">", ">"], [:IDENTIFIER, "c"],
      ["||", "||"], [:IDENTIFIER, "a"],
      [">", ">"], [:IDENTIFIER, "d"], [")", ")"],
      [:BLOCK_BEGIN, "\n"],
      [:BLOCK_END, "else"], [:ELSE, "else"],
      [:BLOCK_BEGIN, "\n"], [:BLOCK_END, "end"]
    ], MERI::Lexer.new.tokenize(code)
  end
end
