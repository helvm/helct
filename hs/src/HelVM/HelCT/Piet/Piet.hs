{-# LANGUAGE OverloadedStrings #-}

module HelVM.HelCT.HelCT where

import Text.Megaparsec
import Text.Megaparsec.Char
import qualified Text.Megaparsec.Char.Lexer as L
import Data.Void
import Data.Functor

type Parser = Parsec Void String

data Program = Program [Routine] deriving (Show)
data Routine = Routine String [String] Block deriving (Show)
data Block = Block [Statement] deriving (Show)
data Statement
  = Assignment String Expression
  | Return (Maybe Expression)
  | Break
  | ExpressionStmt Expression
  | IfElse Condition Block Block
  | If Condition Block
  | While Condition Block
  | For [Statement] Condition [Statement] Block
  deriving (Show)
data Condition = Condition Expression deriving (Show)
data Expression
  = Var String
  | IntLit Int
  | BinOp String Expression Expression
  | Call String [Expression]
  deriving (Show)

-- Whitespace and lexeme handling
sc :: Parser ()
sc = L.space space1 empty empty

lexeme :: Parser a -> Parser a
lexeme = L.lexeme sc

symbol :: String -> Parser String
symbol = L.symbol sc

-- Parsing functions
identifier :: Parser String
identifier = lexeme ((:) <$> letterChar <*> many alphaNumChar)

integer :: Parser Int
integer = lexeme L.decimal

expression :: Parser Expression
expression = try callExpr <|> binOpExpr <|> simpleExpr

callExpr :: Parser Expression
callExpr = do
  func <- identifier
  args <- between (symbol "(") (symbol ")") (expression `sepBy` symbol ",")
  return $ Call func args

binOpExpr :: Parser Expression
binOpExpr = do
  lhs <- simpleExpr
  op <- choice (map symbol ["+", "-", "*", "/"])
  rhs <- expression
  return $ BinOp op lhs rhs

simpleExpr :: Parser Expression
simpleExpr = Var <$> identifier <|> IntLit <$> integer

condition :: Parser Condition
condition = Condition <$> between (symbol "(") (symbol ")") expression

statement :: Parser Statement
statement = try (Assignment <$> identifier <*> (symbol "=" *> expression <* symbol ";"))
        <|> try (Return <$> (symbol "return" *> optional expression <* symbol ";"))
        <|> (symbol "break" *> pure Break)
        <|> ExpressionStmt <$> expression <* symbol ";"

block :: Parser Block
block = Block <$> between (symbol "{") (symbol "}") (many statement)

routine :: Parser Routine
routine = do
  name <- identifier
  params <- between (symbol "(") (symbol ")") (identifier `sepBy` symbol ",")
  body <- block
  return $ Routine name params body

program :: Parser Program
program = Program <$> many routine

-- Main parser entry point
parseProgram :: String -> Either (ParseErrorBundle String Void) Program
parseProgram = runParser (sc *> program <* eof) ""
