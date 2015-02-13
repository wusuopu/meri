class MERI::Parser
  
token IF ELSE
token TRUE FALSE NIL
token DEF
token BLOCK_BEGIN BLOCK_END
token CLASS WHILE RETURN
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
  Root:
    /* */                               { result = Nodes.new([]) }
  | Body                                { result = val[0] }
  ;

  Body:
    Line                                { result = Nodes.new(val) }
  | Body Terminator Line                { result = val[0] << val[2] }
  | Body Terminator                     { result = val[0] }
  ;

  Line:
    Expression
  | Statement
  ;

  Statement:
    Return
  ;

  Expression:
    Value
  | Assign
  | Invocation
  | Code
  | Operation
  | If
  | While
  ;

  AlphaNumberic:
    NUMBER                              { result = NumberNode.new(val[0]) }
  | STRING                              { result = StringNode.new(val[0]) }
  ;
  Literal:
    AlphaNumberic                       { result = val[0] }
  | TRUE                                { result = TrueNode.new() }
  | FALSE                               { result = FalseNode.new() }
  | NIL                                 { result = NilNode.new() }
  ;
  Value:
    Literal
  | AssignValue
  | Parenthetical
  ;

  Return:
    RETURN Expression                   { result = ReturnNode.new(val[1]) }
  | RETURN                              { result = ReturnNode.new(NilNode.new()) }
  ;

  Terminator:
    NEWLINE
  ;

  Operation:
    Expression '||' Expression          { result = CallNode.new(val[0], val[1], [val[2]]) }
  | Expression '&&' Expression          { result = CallNode.new(val[0], val[1], [val[2]]) }
  | Expression '==' Expression          { result = CallNode.new(val[0], val[1], [val[2]]) }
  | Expression '!=' Expression          { result = CallNode.new(val[0], val[1], [val[2]]) }
  | Expression '>' Expression           { result = CallNode.new(val[0], val[1], [val[2]]) }
  | Expression '>=' Expression          { result = CallNode.new(val[0], val[1], [val[2]]) }
  | Expression '<' Expression           { result = CallNode.new(val[0], val[1], [val[2]]) }
  | Expression '<=' Expression          { result = CallNode.new(val[0], val[1], [val[2]]) }
  | Expression '**' Expression          { result = CallNode.new(val[0], val[1], [val[2]]) }
  | Expression '+' Expression           { result = CallNode.new(val[0], val[1], [val[2]]) }
  | Expression '-' Expression           { result = CallNode.new(val[0], val[1], [val[2]]) }
  | Expression '*' Expression           { result = CallNode.new(val[0], val[1], [val[2]]) }
  | Expression '/' Expression           { result = CallNode.new(val[0], val[1], [val[2]]) }
  | Expression '%' Expression           { result = CallNode.new(val[0], val[1], [val[2]]) }
  | Expression '|' Expression           { result = CallNode.new(val[0], val[1], [val[2]]) }
  | Expression '&' Expression           { result = CallNode.new(val[0], val[1], [val[2]]) }
  | Expression '^' Expression           { result = CallNode.new(val[0], val[1], [val[2]]) }
  | '!' Expression                      { result = CallNode.new(val[1], val[0], []) }
  ;

  Assign:
    Assignable '=' Expression           { result = AssignNode.new(val[0], val[2])}
  | Assignable '=' Terminator Expression{ result = AssignNode.new(val[0], val[3])}
  | Assignable '=' '{' Expression '}'   { result = AssignNode.new(val[0], val[3])}
  ;
  AssignValue:
    Assignable                          { result = ValueNode.new(val[0]) }
  ;
  Assignable:
    IDENTIFIER
  | CONSTANT
  ;

  Block:
    BLOCK_BEGIN BLOCK_END               { result = Nodes.new([]) }
  | BLOCK_BEGIN Terminator BLOCK_END    { result = Nodes.new([]) }
  | BLOCK_BEGIN Body BLOCK_END          { result = val[1] }
  | BLOCK_BEGIN Terminator Body BLOCK_END     { result = val[2] }
  ;
  Code:
    '(' ParamList ')' FuncGlyph Block   { result = CodeNode.new(val[1], val[4]) }
  | FuncGlyph Block                     { result = CodeNode.new([], val[1]) }
  ;
  FuncGlyph:
    '->'
  ;
  ParamList:
    /* */                               { result = [] }
  | IDENTIFIER                          { result = val }
  | ParamList ',' IDENTIFIER            { result = val[0] << val[2] }
  ;

  Invocation:
    Value Arguments                     { result = CallNode.new(nil, val[0], val[1]) }
  | Invocation Arguments                { result = CallNode.new(nil, val[0], val[1]) }
  ;
  Arguments:
    '(' ')'                             { result = [] }
  | '(' ArgList ')'                     { result = val[1] }
  ;
  ArgList:
    Expression                          { result = val }
  | ArgList ',' Expression              { result = val[0] << val[2] }
  ;

  Parenthetical:
    '(' Expression ')'                        { result = val[1] }
  | '(' Terminator Expression ')'             { result = val[2] }
  ;


  IfBlock:
    IF Expression Block                 { result = IfNode.new(val[1], val[2]) }
  | IfBlock ELSE IF Expression Block    { result = val[0].add_else(IfNode.new(val[3], val[4])) }
  ;
  If:
    IfBlock                             { result = val[0] }
  | IfBlock ELSE Block                  { result = val[0].add_else(val[2]) }
  ;

  While:
    WHILE Expression Block              { result = WhileNode.new(val[1], val[2]) }
  ;
end


---- header ----
  require 'lexer'
  require 'ast'


---- inner ----
  def parse(code)
    #@yydebug = true
    @tokens = Lexer.new.tokenize code
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
