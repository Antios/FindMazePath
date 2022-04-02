{-# OPTIONS_GHC -Wno-incomplete-patterns #-}
module Solver (run) where

import qualified Data.ByteString.Lazy as B
import Data.Char (intToDigit, toUpper)
import System.Environment ()
import Numeric (readHex)
import Data.Array (Array, Array, array)
import Data.Word ( Word8 )
import Data.Bits ()
import System.IO ()
import System.Exit (exitFailure)

--TODO: SCP files over to timberlea

data Cell = Cell
    {
        wallOnRight  :: Bool,
        wallOnBottom :: Bool
    }
data Maze = Maze
    {
        height, width :: Int,
        cells         :: Array (Int, Int) Cell
    }

run :: FilePath -> IO()
run fileName = do
    txt <- B.readFile fileName
    let bytes = B.unpack txt
    case extractNum bytes of
        Nothing -> do
            putStrLn "File too small"
            exitFailure
        Just (height, bytes') -> do
            case extractNum bytes' of
                Nothing -> do
                    putStrLn "File too small"
                    exitFailure
                Just (width, bytes'') -> print $ makeWallList height width bytes''


extractNum :: [Word8] -> Maybe (Int, [Word8])
extractNum (a:b:c:d:rest) = Just (num, rest)
    where
        num = 0x1000000 * fromIntegral d + 0x10000 * fromIntegral c + 0x100 * fromIntegral b + fromIntegral a
extractNum _ = Nothing

makeWallList :: Int -> Int -> [Word8] -> [Cell]
makeWallList h w bytes = do
    let twoDBitList = map (toBits8 . toInteger) bytes
    let bitListLong = concat twoDBitList
    let bitList = take (w*h*2) bitListLong
    makeCells bitList

toBitsBySize :: Int -> Integer -> [Bool]
toBitsBySize  0 x = []
toBitsBySize sz 0 = [False | i <- [1..sz]]
toBitsBySize sz x =  if k == 0
    then False : toBitsBySize n x
    else True  : toBitsBySize n (x - k*m)
    where n = sz - 1
          m = 2^n
          k = x `div` m

toBits8 :: Integer -> [Bool]
toBits8 = toBitsBySize 8

makeCells :: [Bool] -> [Cell]
makeCells [] = []
makeCells (k:v:t) = Cell { wallOnRight = k, wallOnBottom = v} : makeCells t
    

--makeMaze :: [Word8] -> Maze
--makeMaze bytes = array ((0,0), (getHeight bytes, getWidth bytes) []