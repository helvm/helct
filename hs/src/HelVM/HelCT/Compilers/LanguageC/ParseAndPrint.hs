-- Minimal example: parse a file, and pretty print it again
module HelVM.HelCT.Compilers.LanguageC.ParseAndPrint where

import           Language.C
import           Language.C.System.GCC

import           System.Exit               (ExitCode (..))
import           System.IO                 (hPutStr, hPutStrLn)
import           Text.PrettyPrint.HughesPJ (Doc, hsep, nest, render, text, ($+$), (<+>))

usageMsg :: String -> String
usageMsg prg = render $
  text "Usage:" <+> text prg <+> hsep (map text ["CPP_OPTIONS","input_file.c"])

main :: IO ()
main = do
    let usageErr = (hPutStrLn stderr (usageMsg "./ParseAndPrint") >> exitWith (ExitFailure 1))
    args <- getArgs
    when (null args) usageErr
    let (opts,input_file) = (init $ fromList args, last $ fromList args)

    -- parse
    ast <- errorOnLeftM "Parse Error" $
      parseCFile (newGCC "gcc") Nothing opts input_file
    -- pretty print
    print $ pretty ast

errorOnLeft :: (Show a) => String -> Either a b -> IO b
errorOnLeft msg = either ((error . toText) . ((msg <> ": ")<>).show) return
errorOnLeftM :: (Show a) => String -> IO (Either a b) -> IO b
errorOnLeftM msg action = action >>= errorOnLeft msg
