module HelVM.HelCT.Compilers.LanguageC.Examples.TypeCheck where

import           Language.C
import           Language.C.Analysis.AstAnalysis
import           Language.C.Analysis.TravMonad
import           Language.C.System.GCC

import           Data.List                       (partition)
import           System.Exit                     (ExitCode (..))
import           System.IO                       (hPutStr, hPutStrLn)

processFile :: CLanguage -> [String] -> FilePath -> IO ()
processFile lang cppOpts file =
  do hPutStr stderr $ file <> ": "
     result <- parseCFile (newGCC "gcc") Nothing cppOpts file
     case result of
       Left err -> do
         hPutStrLn stderr ('\n' : show err)
         hPutStrLn stderr "Failed: Parse Error"
         exitWith (ExitFailure 1)
       Right tu -> case runTrav_ (body tu) of
                     Left errs      -> mapM_ (hPutStrLn stderr) ("Error" : map show errs)
                     Right (_,errs) -> mapM_ (hPutStrLn stderr) ("Success" : map show errs)
  where body tu = do modifyOptions (\opts -> opts { language = lang })
                     analyseAST tu

main :: IO ()
main =
  do args <- getArgs
     let (cppOpts, files) = partition (isPrefixOf "-") args
     mapM_ (processFile GNU99 cppOpts) files
