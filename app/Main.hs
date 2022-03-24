module Main where

import System.IO
import Data.Word
import qualified Data.ByteString.Lazy as B
import System.Environment
import Solver

main :: IO ()
main = do
    args <- getArgs
    case args of
        [fileName] -> run fileName
        _          -> putStrLn "USAGE: xxd <file name>"

