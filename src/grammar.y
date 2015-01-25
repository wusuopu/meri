class Parser
  
token IF ELSE
token TRUE FALSE NIL
token CLASS WHILE END
token IDENTIFIER CONSTANT NUMBER STRING NEWLINE

# operator precedence
prechigh
  left    '.'
  right   '!'
  left    '*' '/'
  left    '+' '-'
  left    '>' '>=' '<' '<='
  left    '==' '!='
  left    '&&'
  left    '||'
  right   '='
  left    ','
  left    '->'
preclow

rule

  Constant:
    CONSTANT                            { result = ConstantNode.new(val[0]) }
  ;

  ConstantAssign:
    CONSTANT '=' Expressions            { result = ConstantAssignNode.new(val[0], val[2]) }
  ;

  Variable:
    IDENTIFIER                          { result = VariableNode.new(val[0]) }
  ;

  VariableAssign:
    IDENTIFIER '=' Expressions          { result = VariableAssignNode.new(val[0], val[2]) }
  ;

  Block:
    '{' Expressions '}'                 { result = val[1] }
  ;

  Function:
    '(' Params ')' '->' Block           { result = FunctionNode.new(val[1], val[4]) }
  ;

  Params:
    /* */                               { result = [] }
  | IDENTIFIER                          { result = val }
  | Params ',' IDENTIFIER               { result = val[0] << val[2] }
  ;

  If:
    IF Expressions Block                { result = IfNode.new(val[1], val[2]) }
  ;
end


---- header
  require 'lexer'
  require 'nodes'


---- inner
  def parse(code)
    @tokens = Lexer.new.tokenize code
    do_parse
  end

  def next_token
    @tokens.shift
  end
