module Solver (run) where

import qualified Data.ByteString.Lazy as B
import Data.Char (intToDigit, toUpper)
import System.Environment ()
import Numeric (readHex)
import Data.Array (Array, Array, array)
import Data.Word ( Word8 )
import Data.Bits ()
import System.IO ()

--TODO: SCP files over to timberlea

data Cell = Cell
    {   wallOnRight  :: Bool,
        wallOnBottom :: Bool,
        wallOnLeft   :: Bool,
        wallOnTop    :: Bool
    }

type Maze = Array (Int, Int) Cell

run :: FilePath -> IO()
run fileName = do
    bytes <- B.unpack <$> B.readFile fileName
    print (getCells bytes)

padHex :: String -> String
padHex word =
    if length word < 2
        then "0" ++ word
    else
        word

toHex :: Int -> String
toHex = map toUpper . reverse . recurse
  where recurse n
          | n < 16    = [intToDigit n]
          | otherwise = let (q,r) = n `divMod` 16
                        in intToDigit r : recurse q

toHexList :: [Word8] -> [String]
toHexList = map (padHex . toHex . fromIntegral . toInteger)

concatH :: [Word8] -> String
concatH list = (toHexList list!!3)++(toHexList list!!2)++
               (toHexList list!!1)++head (toHexList list)

concatW :: [Word8] -> String
concatW list = (toHexList list!!7)++(toHexList list!!6)++
               (toHexList list!!5)++(toHexList list!!4)

getHeight :: [Word8] -> Int
getHeight list = fst (head (readHex $ concatH list))

getWidth :: [Word8] -> Int
getWidth list = fst (head (readHex $ concatW list))

getCells :: [Word8] -> [Word8 ]
getCells = drop 8

--makeMaze :: [Word8] -> Maze
--makeMaze bytes = array ((0,0), (getHeight bytes, getWidth bytes) []