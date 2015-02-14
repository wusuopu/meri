# @file lexer.rex
# @author Long Changjin <admin@longchangjin.cn>
# @date 2015-02-10

module MERI
class Lexer
macro
  BLANK         \s+
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
                return            {
  [:RETURN, text]
                }

                [_a-z]\w*         {
  [:IDENTIFIER, text]
                }
                [A-Z]\w*          {
  [:CONSTANT, text]
                }
                [-+]?(0|([1-9]\d*))(.\d+)?([eE][-+]?\d+)?   {
  [:NUMBER, text.to_f]
                }
                "((\\")|([^"]))*" {
  [:STRING, eval(text)]
                }
                '((\\')|([^']))*' {
  [:STRING, eval(text)]
                }

                \n                {
  _newline_action
                }
                ->                {
  @block_stack << :FUNCTION
  [text, text]
                }
                {                 {
  @brace_level += 1
  [text, text]
                }
                }                 {
  @brace_level -= 1
  [text, text]
                }
                \[                {
  @bracket_level += 1
  [text, text]
                }
                \]                {
  @bracket_level -= 1
  [text, text]
                }
                \(                {
  @parenthesis_level += 1
  [text, text]
                }
                \)                {
  @parenthesis_level -= 1
  [text, text]
                }
                \|\||&&|==|!=|<=|>=|\*\*                    {
  [text, text]
                }

                {BLANK}           # no action
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
  end

  def next_token
    return if @ss.eos?

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

  def _newline_action
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
end
end
