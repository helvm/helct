{
module Lexer where
}

tokens :: String -> [Token]
tokens = tokenize

$white = [ \t\n\r]+
$digit = [0-9]
$alpha = [a-zA-Z_]

%%
$white       ;
"return"     { \_ -> Return }
"break"      { \_ -> Break }
"if"         { \_ -> If }
"else"       { \_ -> Else }
"for"        { \_ -> For }
"while"      { \_ -> While }
"asm"        { \_ -> Asm }
"="          { \_ -> Equals }
"+"          { \_ -> Plus }
"-"          { \_ -> Minus }
"*"          { \_ -> Times }
"/"          { \_ -> Divide }
";"          { \_ -> Semicolon }
"("          { \_ -> LParen }
")"          { \_ -> RParen }
"{"          { \_ -> LBrace }
"}"          { \_ -> RBrace }
$digit+      { \n -> Integer (read n) }
$alpha($alpha|$digit)* { \s -> Identifier s }
