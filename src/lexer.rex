# @file lexer.rex
# @author Long Changjin <admin@longchangjin.cn>
# @date 2015-02-10

module MERI
class Lexer
macro
  BLANK         [\ \t\r\f\v]+
  REMARK        ;

rule
                {REMARK}          {
  @state = :COMMENT
  [:REMARK, text]
                }
  :COMMENT      \n                {
  @state = nil
  _newline_action
                }
  :COMMENT      .*(?=$)           { [:COMMENT, text] }

                while             {
  @block_stack << :WHILE
  [:WHILE, text]
                }
                if                {
  @block_stack << :IF
  [:IF, text]
                }
                else              {
  _else_block_action text, :ELSE
                }
                elif              {
  _else_block_action text, :ELIF
                }
                end               {
  [:BLOCK_END, text]
                }
                true              {
  [:TRUE, text]
                }
                false             {
  [:FALSE, text]
                }
                nil               {
  [:NIL, text]
                }
                break             {
  [:BREAK, text]
                }
                next              {
  [:NEXT, text]
                }
                return            {
  [:RETURN, text]
                }

                [_a-z]\w*         {
  _call_begin_action [:IDENTIFIER, text], text
                }
                [A-Z]\w*          {
  _call_begin_action [:CONSTANT, text], text
                }
                [-+]?(0|([1-9]\d*))(\.\d+)?([eE][-+]?\d+)?  {
  _call_begin_action [:NUMBER, text.to_f], text
                }
                "((\\")|([^"]))*" {
  _call_begin_action [:STRING, eval(text)], text
                }
                '((\\')|([^']))*' {
  _call_begin_action [:STRING, eval(text)], text
                }

                \n                {
  _newline_action
                }
                ->                {
  @block_stack << :FUNCTION
  [text, text]
                }
                {                 {
  current_pos = @ss.pos
  res = _call_begin_action [text, text], text
  if current_pos == @ss.pos
    @brace_level += 1
  end
  res
                }
                }                 {
  @brace_level -= 1
  [text, text]
                }
                \[                {
  if @last_token && (
    @last_token[1] == ')' || @last_token[1] == ']' || @last_token[1] == '}' ||
    @last_token[0] == :IDENTIFIER || @last_token[0] == :CONSTANT
    )
    prev_pos = @ss.pos-2
    if prev_pos >= 0 && @ss.string[prev_pos] == ' '
      @ss.pos -= text.size
      @call_noparenthesis_stack << [:CALL_NO_PARENTHESIS, @ss.pos]
      [:CALL_BEGIN, ' ']
    else
      @bracket_level += 1
      @index_stack << [@bracket_level, @ss.pos]
      [:INDEX_BEGIN, '[']
    end
  else
    @bracket_level += 1
    [text, text]
  end
                }
                \]                {
  index_token = @index_stack[-1]
  @bracket_level -= 1
  if index_token && index_token[0] == @bracket_level+1
    @index_stack.pop
    [:INDEX_END, ']']
  else
    [text, text]
  end
                }
                \(                {
  @parenthesis_level += 1
  if @last_token && (
      @last_token[1] == ')' || @last_token[1] == ']' || @last_token[1] == '}' ||
      @last_token[0] == :IDENTIFIER || @last_token[0] == :CONSTANT
    )
      @call_parenthesis_stack << [:CALL_PARENTHESIS, @parenthesis_level, @ss.pos]
      [:CALL_BEGIN, '(']
  else
    [text, text]
  end
                }
                \)                {
  call_parenthesis_token = @call_parenthesis_stack[-1]
  call_noparenthesis_token = @call_noparenthesis_stack[-1]
  if call_parenthesis_token && call_parenthesis_token[1] == @parenthesis_level
    if call_noparenthesis_token && (
        call_noparenthesis_token[-1] > call_parenthesis_token[-1] &&
        @ss.pos > call_noparenthesis_token[-1]
      )
      @call_noparenthesis_stack.pop
      @ss.pos -= text.size
      [:CALL_END, ' ']
    else
      @parenthesis_level -= 1
      @call_parenthesis_stack.pop
      [:CALL_END, ')']
    end
  else
    @parenthesis_level -= 1
    [text, text]
  end
                }
                \|\||&&|==|!=|<=|>=|\*\*                    {
  [text, text]
                }

                {BLANK}           {
  if @ss.eos?
    @last_token = _newline_action false
  else
    nil
  end
                }
                .                 { [text, text] }


inner
  attr_reader   :block_stack, :last_token

  def scan_setup(str)
    @ss = StringScanner.new(str)
    @lineno =  1
    @state  = nil
    @block_stack = []
    @last_token = nil
    @parenthesis_level = 0
    @bracket_level = 0
    @brace_level = 0
    @call_parenthesis_stack = []
    @call_noparenthesis_stack = []
    @index_stack = []

  end

  def next_token
    if @ss.eos?
      if @last_token && @last_token[0] != :NEWLINE
        @last_token = _newline_action false
        return @last_token
      else
        return
      end
    end

    token = nil
    while !@ss.eos?
      token = _next_token
      if !token.is_a?(Array)
        next
      end
      if  token[0] == :REMARK || token[0] == :COMMENT
        next
      end
      break
    end
    @last_token = token
  end

  def tokenize code
    scan_setup(code)
    tokens = []

    while token = next_token
      tokens << token
    end

    tokens
  end

  def _newline_action backspace=true
    if !@last_token
      # skip the header blank line
      return nil
    end
    token = @last_token[0]
    if token == :NEWLINE || token == :BLOCK_BEGIN
      # skip continuous blank line
      return nil
    end

    if @parenthesis_level != 0 || @bracket_level != 0 || @brace_level != 0
      return nil
    end
    operator_list = [
      "||", "&&", "==", "!=", "<=", ">=", "<", ">",
      "**", "+", "-", "*", "/", "%", "|", "&", "^",
      ",", "="
    ]
    if operator_list.include? token
      return nil
    end

    call_token = @call_noparenthesis_stack.pop
    if call_token
      @ss.pos -= 1 if backspace
      return [:CALL_END, "\n"]
    end

    block_state = @block_stack.pop
    block_keywords = [:IF, :ELSE, :ELIF, :WHILE, :FUNCTION]
    if block_state && block_keywords.include?(block_state)
      return [:BLOCK_BEGIN, "\n"]
    end
    [:NEWLINE, "\n"]
  end

  def _else_block_action text, symbol
    if @last_token && (@last_token[0] == :NEWLINE || @last_token[0] == :BLOCK_BEGIN)
      @ss.pos -= text.size
      return [:BLOCK_END, text]
    else
      @block_stack << symbol
      return [symbol, text]
    end
  end

  def _call_begin_action token, text
    if @last_token && (
      @last_token[1] == ')' || @last_token[1] == ']' || @last_token[1] == '}' ||
      @last_token[0] == :IDENTIFIER || @last_token[0] == :CONSTANT
      )
      @ss.pos -= text.size
      @call_noparenthesis_stack << [:CALL_NO_PARENTHESIS, @ss.pos]
      [:CALL_BEGIN, ' ']
    else
      token
    end
  end
end
end
