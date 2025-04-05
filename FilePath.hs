module FilePath (
    AssuredToBe,
    unWrap,
    Absolutable(..),
    AbsoluteFilePath,
    makeAbsolute,
    RootRelativeFilePath,
    rootOf,
    relativizeToRoot,
    (</>),
    dropTrailingPathSeparator,
    splitPath,
    takeName
) where

import FilePath_Internal_IO
    ( RootRelativeFilePath, 
      Absolutable(..),
      AbsoluteFilePath,
      AssuredToBe(..),
      unWrap,
      makeAbsolute,
      relativizeToRoot,
      rootOf )
import qualified System.FilePath as F
import Utilities ((|>), (||>))
import Data.List (uncons)
import Data.Maybe (fromMaybe)
import Data.Bifunctor (first)

(</>) :: AssuredToBe pathType -> String -> AssuredToBe pathType
(AssuredToBe pathType path) </> path' = AssuredToBe pathType ( path F.</> path' )  

splitPath :: AssuredToBe pathType -> (AssuredToBe pathType, [String])
splitPath (AssuredToBe pathType path) = 
    path 
    ||> F.splitPath 
    |> uncons 
    |> fromMaybe ( error ( "Assurance failed on "++show path ) )
    |> first ( AssuredToBe pathType ) 

dropTrailingPathSeparator :: AssuredToBe pathType -> AssuredToBe pathType
dropTrailingPathSeparator (AssuredToBe pathType path ) = AssuredToBe pathType $ F.dropTrailingPathSeparator path

takeName :: AssuredToBe pathType -> String
takeName = 
    unWrap
    |> reverse
    |> dropWhile F.isPathSeparator
    |> takeWhile (not.F.isPathSeparator)
    |> reverse