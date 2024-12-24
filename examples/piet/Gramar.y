{
module Grammar where
}

%token
    IDENTIFIER { Identifier $$ }
    INTEGER    { Integer $$ }
    RETURN     { Return }
    BREAK      { Break }
    IF         { If }
    ELSE       { Else }
    FOR        { For }
    WHILE      { While }
    ASM        { Asm }
    EQUALS     { Equals }
    PLUS       { Plus }
    MINUS      { Minus }
    TIMES      { Times }
    DIVIDE     { Divide }
    SEMICOLON  { Semicolon }
    LPAREN     { LParen }
    RPAREN     { RParen }
    LBRACE     { LBrace }
    RBRACE     { RBrace }

%name parseProgram
%monad { Parser }

%%

program :: { [Routine] }
    : routine_list { $1 }

routine_list :: { [Routine] }
    : routine { [$1] }
    | routine_list routine { $2 : $1 }

routine :: { Routine }
    : IDENTIFIER LPAREN identifier_list RPAREN block { Routine $1 $3 $5 }

identifier_list :: { [String] }
    : IDENTIFIER { [$1] }
    | identifier_list ',' IDENTIFIER { $3 : $1 }

block :: { [Statement] }
    : LBRACE statement_list RBRACE { $2 }

statement_list :: { [Statement] }
    : statement { [$1] }
    | statement_list statement { $2 : $1 }

statement :: { Statement }
    : assignment SEMICOLON { AssignmentStmt $1 }
    | RETURN expression_opt SEMICOLON { ReturnStmt $2 }
    | BREAK SEMICOLON { BreakStmt }
    | block { BlockStmt $1 }
    | if_else_statement { $1 }
    | loop_statement { $1 }

assignment :: { Assignment }
    : IDENTIFIER EQUALS expression { Assignment $1 $3 }

if_else_statement :: { Statement }
    : IF LPAREN expression RPAREN block ELSE block { IfElseStmt $3 $5 $7 }
    | IF LPAREN expression RPAREN block { IfStmt $3 $5 }

loop_statement :: { Statement }
    : WHILE LPAREN expression RPAREN block { WhileStmt $3 $5 }
    | FOR LPAREN statement SEMICOLON expression SEMICOLON statement RPAREN block { ForStmt $3 $5 $7 $9 }

expression_opt :: { Maybe Expression }
    : expression { Just $1 }
    | { Nothing }

expression :: { Expression }
    : term expression_rest { foldl (\acc (op, t) -> BinOp op acc t) $1 $2 }

expression_rest :: { [(Operator, Expression)] }
    : PLUS term { [(Plus, $2)] }
    | MINUS term { [(Minus, $2)] }
    | { [] }

term :: { Expression }
    : factor term_rest { foldl (\acc (op, f) -> BinOp op acc f) $1 $2 }

term_rest :: { [(Operator, Expression)] }
    :

