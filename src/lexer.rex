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
  if @last_token && (@last_token[0] == :NEWLINE || @last_token[0] == :BLOCK_BEGIN)
    @ss.pos -= text.size
    [:BLOCK_END, text]
  else
    [:ELSE, text]
  end
                }
                end               {
  [:BLOCK_END, text]
                }
                true              {
  [:TRUE, text]
                }
                false              {
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

    block_state = @block_stack.pop
    block_keywords = [:IF, :ELSE, :WHILE, :FUNCTION]
    if block_state && block_keywords.include?(block_state)
      return [:BLOCK_BEGIN, "\n"]
    end
    [:NEWLINE, "\n"]
  end
end
end
