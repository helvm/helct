{
-- At the top of the file, we define the module and its imports, similarly to Haskell.
module HelVM.HelCT.Compilers.MiniML.Lexer
  ( -- * Invoking Alex
    Alex
  , AlexPosn (..)
  , alexGetInput
  , alexError
  , runAlex
  , alexMonadScan

  , Range (..)
  , RangedToken (..)
  , Token (..)
  , scanMany
  ) where

import Control.Monad (when)
import Data.ByteString.Lazy.Char8 (ByteString)
import qualified Data.ByteString.Lazy.Char8 as BS
import Data.Scientific (Scientific)
}

%wrapper "monadUserState-bytestring"

$digit = [0-9]
$alpha = [a-zA-Z]

@id = ($alpha | \_) ($alpha | $digit | \_ | \' | \?)*

@exponent = e (\- | \+)? $digit+

tokens :-

<0> $white+ ;

<0>       "(*" { nestComment `andBegin` comment }
<0>       "*)" { \_ _ -> alexError "Error: unexpected closing comment" }
<comment> "(*" { nestComment }
<comment> "*)" { unnestComment }
<comment> .    ;
<comment> \n   ;

-- Note that . doesn't match newlines, which is what we want.
<0> "#" .* ;

-- Keywords
<0> let     { tok Let }
<0> in      { tok In }
<0> if      { tok If }
<0> then    { tok Then }
<0> else    { tok Else }

-- Arithmetic operators
<0> "+"     { tok Plus }
<0> "-"     { tok Minus }
<0> "*"     { tok Times }
<0> "/"     { tok Divide }

-- Comparison operators
<0> "="     { tok Eq }
<0> "<>"    { tok Neq }
<0> "<"     { tok Lt }
<0> "<="    { tok Le }
<0> ">"     { tok Gt }
<0> ">="    { tok Ge }

-- Logical operators
<0> "&"     { tok And }
<0> "|"     { tok Or }

-- Parenthesis
<0> "("     { tok LPar }
<0> ")"     { tok RPar }

-- Lists
<0> "["     { tok LBrack }
<0> "]"     { tok RBrack }
<0> ","     { tok Comma }

-- Types
<0> ":"     { tok Colon }
<0> "->"    { tok Arrow }

-- Projection
<0> \.      { tok Dot }

-- Exercise 3 bonus:
-- Pattern matching
<0> match   { tok Match }
<0> with    { tok With }

-- Identifiers
<0> @id     { tokId }

-- Constants
-- Exercise 1:
<0> $digit+ (\. $digit+)? @exponent? { tokNumber }

<0> \"        { enterString `andBegin` string }
<string> \"   { exitString `andBegin` 0 }
<string> \\\\ { emit '\\' }
<string> \\\" { emit '"' }
<string> \\n  { emit '\n' }
<string> \\t  { emit '\t' }
<string> .    { emitCurrent }

{
data AlexUserState = AlexUserState
  { nestLevel :: Int
  , strStart :: AlexPosn
  , strBuffer :: [Char]
  }

alexInitUserState :: AlexUserState
alexInitUserState = AlexUserState
  { nestLevel = 0
  , strStart = AlexPn 0 0 0
  , strBuffer = []
  }

get :: Alex AlexUserState
get = Alex $ \s -> Right (s, alex_ust s)

put :: AlexUserState -> Alex ()
put s' = Alex $ \s -> Right (s{alex_ust = s'}, ())

modify :: (AlexUserState -> AlexUserState) -> Alex ()
modify f = Alex $ \s -> Right (s{alex_ust = f (alex_ust s)}, ())

alexEOF :: Alex RangedToken
alexEOF = do
  (pos, _, _, _) <- alexGetInput
  startCode <- alexGetStartCode
  when (startCode == comment) $
    alexError "Error: unclosed comment"
  when (startCode == string) $
    alexError "Error: unclosed string"
  pure $ RangedToken EOF (Range pos pos)

data Range = Range
  { start :: AlexPosn
  , stop :: AlexPosn
  } deriving (Eq, Show)

data RangedToken = RangedToken
  { rtToken :: Token
  , rtRange :: Range
  } deriving (Eq, Show)

data Token
  -- Identifiers
  = Identifier ByteString
  -- Constants
  | String ByteString
  | Number Scientific
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
  | VBar
  -- Projection
  | Dot
  -- Patern matching
  | Match
  | With
  -- EOF
  | EOF
  deriving (Eq, Show)

mkRange :: AlexInput -> Int64 -> Range
mkRange (start, _, str, _) len = Range{start = start, stop = stop}
  where
    stop = BS.foldl' alexMove start $ BS.take len str

tok :: Token -> AlexAction RangedToken
tok ctor inp len =
  pure RangedToken
    { rtToken = ctor
    , rtRange = mkRange inp len
    }

tokId, tokNumber :: AlexAction RangedToken
tokId inp@(_, _, str, _) len =
  pure RangedToken
    { rtToken = Identifier $ BS.take len str
    , rtRange = mkRange inp len
    }
tokNumber inp@(_ ,_, str, _) len =
  pure RangedToken
    { rtToken = Number $ read $ BS.unpack $ BS.take len str
    , rtRange = mkRange inp len
    }

enterString, exitString :: AlexAction RangedToken
enterString inp@(pos, _, _, _) len = do
  modify $ \s -> s{strStart = pos, strBuffer = '"' : strBuffer s}
  skip inp len
exitString inp@(pos, _, _, _) len = do
  s <- get
  put s{strStart = AlexPn 0 0 0, strBuffer = []}
  pure RangedToken
    { rtToken = String $ BS.pack $ reverse $ '"' : strBuffer s
    , rtRange = Range (strStart s) (alexMove pos '"')
    }

emit :: Char -> AlexAction RangedToken
emit c inp@(_, _, str, _) len = do
  modify $ \s -> s{strBuffer = c : strBuffer s}
  skip inp len

emitCurrent :: AlexAction RangedToken
emitCurrent inp@(_, _, str, _) len = do
  modify $ \s -> s{strBuffer = BS.head str : strBuffer s}
  skip inp len

nestComment, unnestComment :: AlexAction RangedToken
nestComment input len = do
  modify $ \s -> s{nestLevel = nestLevel s + 1}
  skip input len
unnestComment input len = do
  state <- get
  let level = nestLevel state - 1
  put state{nestLevel = level}
  when (level == 0) $
    alexSetStartCode 0
  skip input len

scanMany :: ByteString -> Either String [RangedToken]
scanMany input = runAlex input go
  where
    go = do
      output <- alexMonadScan
      if rtToken output == EOF
        then pure [output]
        else (output :) <$> go
}
