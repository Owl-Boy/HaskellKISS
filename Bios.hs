module BIOS (
    main
) where

import System.Environment (getEnv)
import Target_IO (Target, targetPath)
import Utilities ( (|>))
import FilePath (RootRelativeFilePath, rootOf)
import Directory (FileTree (..))
import qualified Options
import Directory_IO (mkLinkAt, fileTreeAlong)
import qualified Modules
import Control.Monad ((>=>))
import Control.Applicative (liftA2)

biosReceiver :: IO String
biosReceiver = getEnv "HIE_BIOS_OUTPUT"

sendToBiosReceiver :: [String] -> IO ()
sendToBiosReceiver lines_ =
    biosReceiver
    >>= ( \ receiver -> writeFile receiver (unlines lines_) )

-- | list of options which begin with '-', as those are the only ones accepted by haskell-language-server
biosOptions :: FileTree RootRelativeFilePath -> IO [String]
biosOptions =
    Options.options
    |> filter (head|>(=='-'))
    |> pure

-- clear the previos links made in root
-- clearPreviousLinks :: IO [()]
-- clearPreviousLinks =
--     root
--     >>= listDirPaths
--     >>= filterM isModule
--     >>= mapM removeFile

-- | add the action of making the links to modules at the root\\
-- as a side effect in /modules/
biosModules :: FileTree RootRelativeFilePath -> IO [String]
biosModules =
    Modules.modules
    |> mapM linkAtRoot
    where
        linkAtRoot x = let p = path x in mkLinkAt (rootOf p) p

{- |

@root@ :=  location of hie.yaml config file

All filePaths are taken relative to @root@, except for @root@ itself

/target/ := the haskell program file concerned

An /options.txt/ file should contain all the options an user wants to be passed to ghc.

Find an /options.txt/ file in one of the ancestor directories of target.\\
In particular, take the one that is closest to target.\\
Extract from it a list of reevant options.

/isModule/ := is a file beginning with a capital letter and having extension ".hs" or ".lhs"

Find all modules (in the ancestor directories of target) which target might potentially import,\\
and if there are muliple files with the same name,\\
take the one which is closer to target.

Take all the modules in the Modules folder, ignoring those whose names have already been seen in the ancestor directories of target.\\
If there are multiple files with the same name, take the one which is closest to root.

Put links to all these modules in @root@, for haskell-language-server to access.\\
Haskell-language-server cannot access deeper than @root@. :(

Write all options and (paths to module links)\\
to the path specified by the HIE_BIOS_OUTPUT environment variable,\\
as is required by haskell-language-server bios mode.

-}

main :: Target -> IO ()
main =
    ( fileTreeAlong.targetPath )
    >=> (
        liftA2 (++)
        <$> biosOptions
        <*> biosModules
    )
    >=> sendToBiosReceiver