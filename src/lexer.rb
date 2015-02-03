#!/usr/bin/env ruby
#-*- coding:utf-8 -*-
#
# @file lexer.rb
# @author Long Changjin <admin@longchangjin.cn>
# @date 2015-01-21


module MERI
  class Lexer
    KEYWORDS = [
      'class', 'if', 'else',
      'true', 'false', 'nil',
      'def', 'while', 'end'
    ]
    def tokenize code
      code.chomp!
      tokens = []

      i = 0
      while i < code.size
        chunk = code[i..-1]

        if identifier = chunk[/\A([_a-z]\w*)/, 1]
          if KEYWORDS.include? identifier
            tokens << [identifier.upcase.to_sym, identifier]
          else
            tokens << [:IDENTIFIER, identifier]
          end
          i += identifier.size
        elsif constant = chunk[/\A([A-Z]\w*)/, 1]
          tokens << [:CONSTANT, constant]
          i += constant.size
        elsif number = chunk[/\A([-+]?(0|([1-9]\d*))(.\d+)?([eE][-+]?\d+)?)/, 1]
          tokens << [:NUMBER, number.to_f]
          i += number.size
        elsif string = chunk[/\A"(((\\")|([^"]))*)"/, 1]
          # string with double quote
          i += string.size + 2
          tokens << [:STRING, string.gsub('\"', '"')]
        elsif string = chunk[/\A'(((\\')|([^']))*)'/, 1]
          # string with single quote
          i += string.size + 2
          tokens << [:STRING, string.gsub("\\'", "'")]
        elsif newline = chunk[/\A(\n)/m, 1]
          tokens << [:NEWLINE, "\n"]
          i += newline.size
        elsif operator = chunk[/\A(\|\||&&|==|!=|<=|>=|\*\*|->)/, 1]
          tokens << [operator, operator]
          i += operator.size
        elsif chunk.match(/\A /)
          i += 1
        else
          value = chunk[0, 1]
          tokens << [value, value]
          i += 1
        end
      end

      tokens
    end
  end
end
