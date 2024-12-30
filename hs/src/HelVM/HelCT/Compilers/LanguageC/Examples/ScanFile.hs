-- Simple example demonstrating the API: parse a file, and print its definition table
module HelVM.HelCT.Compilers.LanguageC.Examples.ScanFile where

import           Language.C
import           Language.C.Analysis
import           Language.C.System.GCC

import           Data.List                 (isInfixOf)
import           System.Environment        (getEnvironment)
import           System.Exit               (ExitCode (..))
import           System.FilePath
import           System.IO                 (hPrint, hPutStrLn)
import           Text.PrettyPrint.HughesPJ (Doc, hsep, nest, render, text, ($+$), (<+>))

usageMsg :: String -> String
usageMsg prg = render $
  text "Usage:" <+> text prg <+> hsep (map text ["CPP_OPTIONS","input_file.c","[file-pattern]"]) $+$
  nest 4
    (text "Environment Variables" $+$
      nest 4 (
         hsep [text "TRACE_EVENTS", text "trace definition events as they occur"]
      )
  )

main :: IO ()
main = do
    let usageErr = hPutStrLn stderr (usageMsg "./ScanFile") >> exitWith (ExitFailure 1)
    args <- getArgs
    when (null args) usageErr
    doTraceDecls <- fmap (("TRACE_EVENTS" `elem`). map fst) getEnvironment
    -- get cpp options and input file
    let (pat,opts,input_file) = processArgs (hasExtension (last $ fromList args)) args

    -- parse
    ast <- errorOnLeftM "Parse Error" $ parseCFile (newGCC "gcc") Nothing opts input_file

    -- analyze
    (globals,warnings) <- errorOnLeft "Semantic Error" $ runTrav_ $ traversal doTraceDecls ast

    -- print
    mapM_ (hPrint stderr) warnings
    print $ pretty $ filterGlobalDecls (maybe False (fileOfInterest pat input_file) . fileOfNode) globals

    where
    traversal False ast = analyseAST ast
    traversal True  ast = withExtDeclHandler (analyseAST ast) $ \ext_decl ->
                          trace (declTrace ext_decl) pass

    fileOfInterest (Just pat) _ file_name       = pat `isInfixOf` file_name
    fileOfInterest Nothing input_file file_name = fileOfInterest' (splitExtensions input_file) (splitExtension file_name)
    fileOfInterest' (c_base,c_ext) (f_base,f_ext) | takeBaseName c_base /= takeBaseName f_base = False
                                                  | f_ext == ".h" && c_ext == ".c"  = False
                                                  | otherwise = True
processArgs :: Bool -> [a] -> (Maybe a, [a], a)
processArgs True  args = (Nothing, init $ fromList args, last $ fromList args)
processArgs False args = let (pat', args') = (last $ fromList args, init $ fromList args) in (Just pat', init $ fromList args', last $ fromList args')

errorOnLeft :: (Show a) => String -> Either a b -> IO b
errorOnLeft msg = either ((error . toText) . ((msg <> ": ")<>).show) return
errorOnLeftM :: (Show a) => String -> IO (Either a b) -> IO b
errorOnLeftM msg action = action >>= errorOnLeft msg

declTrace :: DeclEvent -> String
declTrace event = render $ case event of
                                TagEvent tag_def      -> text "Tag:" <+> pretty tag_def <+> file tag_def
                                DeclEvent ident_decl  -> text "Decl:" <+> pretty ident_decl <+> file ident_decl
                                ParamEvent pd         -> text "Param:" <+> pretty pd  <+> file pd
                                LocalEvent ident_decl -> text "Local:" <+> pretty ident_decl  <+> file ident_decl
                                TypeDefEvent tydef    -> text "Typedef:" <+> pretty tydef <+> file tydef
                                AsmEvent _block       -> text "Assembler block"
    where
    file :: (CNode a) => a -> Doc
    file = text . show . posOfNode . nodeInfo
