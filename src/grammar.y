class MERI::Parser
  
token IF ELSE ELIF
token TRUE FALSE NIL
token BLOCK_BEGIN BLOCK_END
token CALL_BEGIN CALL_END
token INDEX_BEGIN INDEX_END
token CLASS WHILE RETURN BREAK NEXT
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
  | BREAK                               { result = BreakLoopNode.new }
  | NEXT                                { result = NextLoopNode.new }
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
  ListLiteral:
    '[' ']'                             { result = ListNode.new([]) }
  | '[' ArgList ']'                     { result = ListNode.new(val[1]) }
  ;
  HashLiteral:
    '{' '}'                             { result = HashNode.new({}) }
  | '{' HashObjList '}'                 { result = HashNode.new(val[1]) }
  ;
  HashObjList:
    Expression ':' Expression           { result = {val[0] => val[2]} }
  | HashObjList ',' Expression ':' Expression                       { val[0][val[2]] = val[4]; result = val[0]; }
  ;
  Literal:
    AlphaNumberic                       { result = val[0] }
  | ListLiteral                         { result = val[0] }
  | HashLiteral                         { result = val[0] }
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
  | Expression INDEX_BEGIN Expression INDEX_END                     { result = CallNode.new(val[0], '[]', [val[2]]) }
  | Expression INDEX_BEGIN Expression INDEX_END '=' Expression      { result = CallNode.new(val[0], '[]=', [val[2], val[5]]) }
  | '!' Expression                      { result = CallNode.new(val[1], val[0], []) }
  ;

  Assign:
    Assignable '=' Expression           { result = AssignNode.new(val[0], val[2])}
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
  | BLOCK_BEGIN Body BLOCK_END          { result = val[1] }
  ;
  Code:
    '(' ParamList ')' FuncGlyph Block   { result = CodeNode.new(val[1], val[4]) }
  | '(' IDENTIFIER ')' FuncGlyph Block  { result = CodeNode.new([val[1]], val[4]) }
  | FuncGlyph Block                     { result = CodeNode.new([], val[1]) }
  | '(' ')' FuncGlyph Block             { result = CodeNode.new([], val[3]) }
  ;
  FuncGlyph:
    '->'
  ;
  ParamList:
    IDENTIFIER ',' IDENTIFIER           { result = [val[0], val[2]] }
  | ParamList ',' IDENTIFIER            { result = val[0] << val[2] }
  ;

  Invocation:
    Value Arguments                     { result = CallNode.new(nil, val[0], val[1]) }
  | Invocation Arguments                { result = CallNode.new(nil, val[0], val[1]) }
  ;
  Arguments:
    CALL_BEGIN CALL_END                 { result = [] }
  | CALL_BEGIN ArgList CALL_END         { result = val[1] }
  ;
  ArgList:
    Expression                          { result = val }
  | ArgList ',' Expression              { result = val[0] << val[2] }
  ;

  Parenthetical:
    '(' Expression ')'                  { result = val[1] }
  ;


  IfBlock:
    IF Expression Block                 { result = IfNode.new(val[1], val[2]) }
  | IfBlock ELIF Expression Block       { result = val[0].add_else(IfNode.new(val[2], val[3])) }
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
