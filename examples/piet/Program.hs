module HelVM.HelCT.Compilers.Piet.Program

data Program = Program [Routine]
data Routine = Routine String [String] [Statement]

data Statement
    = AssignmentStmt Assignment
    | ReturnStmt (Maybe Expression)
    | BreakStmt
    | BlockStmt [Statement]
    | IfStmt Expression [Statement]
    | IfElseStmt Expression [Statement] [Statement]
    | WhileStmt Expression [Statement]
    | ForStmt Statement Expression Statement [Statement]

data Assignment = Assignment String Expression

data Expression
    = IntLiteral Int
    | Var String
    | BinOp Operator Expression Expression

data Operator = Plus | Minus | Times | Divide
