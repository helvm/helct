module HelVM.HelCT.Compilers.MiniML.Token where

data Token
  -- Identifiers
  = Identifier ByteString
  -- Constants
  | String ByteString
  | Integer Integer
  -- Keywords
  | Let
  | In
  | If
  | Then
  | Else
  -- Arithmetic operators
  | Plus
  | Minus
  | Times
  | Divide
  -- Comparison operators
  | Eq
  | Neq
  | Lt
  | Le
  | Gt
  | Ge
  -- Logical operators
  | And
  | Or
  -- Parenthesis
  | LPar
  | RPar
  -- Lists
  | Comma
  | LBrack
  | RBrack
  -- Types
  | Colon
  | Arrow
  -- EOF
  | EOF
  deriving stock (Eq, Show)
