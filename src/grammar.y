class Parser
  
token IF ELSE
token TRUE FALSE NIL
token CLASS WHILE END
token IDENTIFIER CONSTANT NUMBER STRING NEWLINE

# operator precedence
prechigh
  left    '.'
  right   '!'
  left    '**'
  left    '*' '/' '%'
  left    '+' '-'
  left    '|' '&' '^'
  left    '>' '>=' '<' '<='
  left    '==' '!='
  left    '&&'
  left    '||'
  right   '='
  left    ','
  left    '->'
preclow

rule
  Stm:
    /* */                               { result = Nodes.new([]) }
  | Expressions                         { result = val[0] }
  ;

  Expressions:
    Expression                          { result = Nodes.new(val) }
  | Expressions Terminator Expression   { result = val[0] << val[2] }
  | Expressions Terminator              { result = val[0] }
  | Terminator                          { result = Nodes.new([]) }
  ;

  Expression:
    Literal
  | FunctionCall
  | Operator
  | Constant
  | ConstantAssign
  | Variable
  | VariableAssign
  | Function
  | While
  | If
  | '(' Expression ')'                  { result = val[1] }
  ;

  Terminator:
    NEWLINE
  ;

  Literal:
    NUMBER                              { result = NumberNode.new(val[0]) }
  | STRING                              { result = StringNode.new(val[0]) }
  | TRUE                                { result = TrueNode.new() }
  | FALSE                               { result = FalseNode.new() }
  | NIL                                 { result = NilNode.new() }
  ;

  FunctionCall:
  | IDENTIFIER Arguments                { result = FunctionCallNode.new(nil, val[0], val[1]) }
  | Expression '.' IDENTIFIER           { result = FunctionCallNode.new(val[0], val[2], []) }
  | Expression '.' IDENTIFIER Arguments { result = FunctionCallNode.new(val[0], val[2], val[3]) }
  ;

  Arguments:
    '(' ')'                             { result = [] }
  | '(' ArgList ')'                     { result = val[1] }
  | ArgList                             { result = val[0] }
  ;

  ArgList:
    Expression                          { result = val }
  | ArgList ',' Expression              { result = val[0] << val[2] }
  ;

  Operator:
    Expression '||' Expression          { result = FunctionCallNode.new(val[0], val[1], [val[2]]) }
  | Expression '&&' Expression          { result = FunctionCallNode.new(val[0], val[1], [val[2]]) }
  | Expression '==' Expression          { result = FunctionCallNode.new(val[0], val[1], [val[2]]) }
  | Expression '!=' Expression          { result = FunctionCallNode.new(val[0], val[1], [val[2]]) }
  | Expression '>' Expression           { result = FunctionCallNode.new(val[0], val[1], [val[2]]) }
  | Expression '>=' Expression          { result = FunctionCallNode.new(val[0], val[1], [val[2]]) }
  | Expression '<' Expression           { result = FunctionCallNode.new(val[0], val[1], [val[2]]) }
  | Expression '<=' Expression          { result = FunctionCallNode.new(val[0], val[1], [val[2]]) }
  | Expression '**' Expression          { result = FunctionCallNode.new(val[0], val[1], [val[2]]) }
  | Expression '+' Expression           { result = FunctionCallNode.new(val[0], val[1], [val[2]]) }
  | Expression '-' Expression           { result = FunctionCallNode.new(val[0], val[1], [val[2]]) }
  | Expression '*' Expression           { result = FunctionCallNode.new(val[0], val[1], [val[2]]) }
  | Expression '/' Expression           { result = FunctionCallNode.new(val[0], val[1], [val[2]]) }
  | Expression '%' Expression           { result = FunctionCallNode.new(val[0], val[1], [val[2]]) }
  | Expression '|' Expression           { result = FunctionCallNode.new(val[0], val[1], [val[2]]) }
  | Expression '&' Expression           { result = FunctionCallNode.new(val[0], val[1], [val[2]]) }
  | Expression '^' Expression           { result = FunctionCallNode.new(val[0], val[1], [val[2]]) }
  | '!' Expression                      { result = FunctionCallNode.new(val[1], val[0], []) }
  ;

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

  While:
    WHILE Expressions Block             { result = WhileNode.new(val[1], val[2]) }
  ;

  If:
    IF Expressions Block                { result = IfNode.new(val[1], val[2]) }
  ;
end


---- header ----
  require 'lexer'
  require 'ast'


---- inner ----
  def parse(code)
    @tokens = Lexer.new.tokenize code
    do_parse
  end

  def next_token
    @tokens.shift
  end
