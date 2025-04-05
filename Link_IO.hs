module Link_IO (
    mkHardLink
) where

-- if Windows
import System.Win32.HardLink (createHardLink)
mkHardLink :: FilePath -> FilePath -> IO ()
mkHardLink = createHardLink
-- if POSIX
-- import System.Posix.Files (createLink)
-- mkHardLink :: FilePath -> FilePath -> IO ()
-- mkHardLink = createLink