module HelVM.HelCT.Compilers.LanguageC.Examples.DumpAst where

import           Language.C                (parseCFile)
import           Language.C.System.GCC     (newGCC)

import           System.Exit               (ExitCode (ExitFailure))
import           System.IO                 (hPutStrLn)
import           Text.PrettyPrint.HughesPJ (hsep, render, text, (<+>))
import qualified Text.Show
import           Text.Show                 (ShowS, showString, shows)


usageMsg :: String -> String
usageMsg prg = render $ text "Usage:" <+> text prg <+> hsep (map text ["CPP_OPTIONS","input_file.c"])

main :: IO ()
main = do
  let usageErr = hPutStrLn stderr (usageMsg "./ParseAndPrint") >> exitWith (ExitFailure 1)
  args <- getArgs
  when (null args) usageErr
  let (opts,input_file) = (init $ fromList args, last $ fromList args)
  ast <- errorOnLeftM "Parse Error" $ parseCFile (newGCC "gcc") Nothing opts input_file
  putStrLn $ decorate (shows (fmap (const ShowPlaceholder) ast)) ""

errorOnLeft :: (Show a) => Text -> Either a b -> IO b
errorOnLeft msg = either (error . ((msg <> ": ")<>).show) return

errorOnLeftM :: (Show a) => Text -> IO (Either a b) -> IO b
errorOnLeftM msg action = action >>= errorOnLeft msg

data ShowPlaceholder = ShowPlaceholder
instance Show ShowPlaceholder where
  showsPrec _ ShowPlaceholder = showString "_"

decorate :: ShowS -> ShowS
decorate app = showString "(" . app . showString ")"
