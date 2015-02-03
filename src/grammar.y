class MERI::Parser
  
token IF ELSE
token TRUE FALSE NIL
token DEF
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
preclow

rule
  Stm:
    /* */                               { result = MERI::Nodes.new([]) }
  | Expressions                         { result = val[0] }
  ;

  Expressions:
    Expression                          { result = MERI::Nodes.new(val) }
  | Terminator Expression               { result = MERI::Nodes.new(val[1]) }
  | Expressions Terminator Expression   { result = val[0] << val[2] }
  | Expressions Terminator              { result = val[0] }
  | Terminator                          { result = MERI::Nodes.new([]) }
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
    NUMBER                              { result = MERI::NumberNode.new(val[0]) }
  | STRING                              { result = MERI::StringNode.new(val[0]) }
  | TRUE                                { result = MERI::TrueNode.new() }
  | FALSE                               { result = MERI::FalseNode.new() }
  | NIL                                 { result = MERI::NilNode.new() }
  ;

  Constant:
    CONSTANT                            { result = MERI::ConstantNode.new(val[0]) }
  ;

  ConstantAssign:
    CONSTANT '=' Expression            { result = MERI::ConstantAssignNode.new(val[0], val[2]) }
  ;

  Variable:
    IDENTIFIER                          { result = MERI::VariableNode.new(val[0]) }
  ;

  VariableAssign:
    IDENTIFIER '=' Expression          { result = MERI::VariableAssignNode.new(val[0], val[2]) }
  ;

  FunctionCall:
  | IDENTIFIER Arguments                { result = MERI::FunctionCallNode.new(nil, val[0], val[1]) }
  | Expression '.' IDENTIFIER           { result = MERI::FunctionCallNode.new(val[0], val[2], []) }
  | Expression '.' IDENTIFIER Arguments { result = MERI::FunctionCallNode.new(val[0], val[2], val[3]) }
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
    Expression '||' Expression          { result = MERI::FunctionCallNode.new(val[0], val[1], [val[2]]) }
  | Expression '&&' Expression          { result = MERI::FunctionCallNode.new(val[0], val[1], [val[2]]) }
  | Expression '==' Expression          { result = MERI::FunctionCallNode.new(val[0], val[1], [val[2]]) }
  | Expression '!=' Expression          { result = MERI::FunctionCallNode.new(val[0], val[1], [val[2]]) }
  | Expression '>' Expression           { result = MERI::FunctionCallNode.new(val[0], val[1], [val[2]]) }
  | Expression '>=' Expression          { result = MERI::FunctionCallNode.new(val[0], val[1], [val[2]]) }
  | Expression '<' Expression           { result = MERI::FunctionCallNode.new(val[0], val[1], [val[2]]) }
  | Expression '<=' Expression          { result = MERI::FunctionCallNode.new(val[0], val[1], [val[2]]) }
  | Expression '**' Expression          { result = MERI::FunctionCallNode.new(val[0], val[1], [val[2]]) }
  | Expression '+' Expression           { result = MERI::FunctionCallNode.new(val[0], val[1], [val[2]]) }
  | Expression '-' Expression           { result = MERI::FunctionCallNode.new(val[0], val[1], [val[2]]) }
  | Expression '*' Expression           { result = MERI::FunctionCallNode.new(val[0], val[1], [val[2]]) }
  | Expression '/' Expression           { result = MERI::FunctionCallNode.new(val[0], val[1], [val[2]]) }
  | Expression '%' Expression           { result = MERI::FunctionCallNode.new(val[0], val[1], [val[2]]) }
  | Expression '|' Expression           { result = MERI::FunctionCallNode.new(val[0], val[1], [val[2]]) }
  | Expression '&' Expression           { result = MERI::FunctionCallNode.new(val[0], val[1], [val[2]]) }
  | Expression '^' Expression           { result = MERI::FunctionCallNode.new(val[0], val[1], [val[2]]) }
  | Expression '->' Expression           { result = MERI::FunctionCallNode.new(val[0], val[1], [val[2]]) }
  | '!' Expression                      { result = MERI::FunctionCallNode.new(val[1], val[0], []) }
  ;

  Block:
    '{' Expressions '}'                 { result = val[1] }
  ;

  Function:
    DEF IDENTIFIER '(' Params ')' Block    { result = MERI::FunctionNode.new(val[1], val[3], val[5]) }
  ;

  Params:
    /* */                               { result = [] }
  | IDENTIFIER                          { result = val }
  | Params ',' IDENTIFIER               { result = val[0] << val[2] }
  ;

  While:
    WHILE Expression Block             { result = MERI::WhileNode.new(val[1], val[2]) }
  ;

  If:
    IF Expression Block                { result = MERI::IfNode.new(val[1], val[2]) }
  ;
end


---- header ----
  require 'lexer'
  require 'ast'


---- inner ----
  def parse(code)
    @tokens = MERI::Lexer.new.tokenize code
    do_parse
  end

  def next_token
    @tokens.shift
  end

  def on_error(error_token_id, error_value, value_stack)
    puts "error_token_id: #{error_token_id}"
    puts "error_value: #{error_value}"
    puts "value_stack: #{value_stack}"
  end
