module Solver (run) where

import qualified Data.ByteString.Lazy as B
import Data.Char (intToDigit, toUpper)
import System.Environment ()
import Numeric (readHex)
import Data.Array (Array, Array, array, listArray, (!))
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

run :: FilePath -> FilePath -> IO()
run fileName pathFileName = do
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
                Just (width, bytes'') -> display pathFileName (findRPath (makeMaze height width bytes'') (0,0) (0,0))


extractNum :: [Word8] -> Maybe (Int, [Word8])
extractNum (a:b:c:d:rest) = Just (num, rest)
    where
        num = 0x1000000 * fromIntegral d + 0x10000 * fromIntegral c + 0x100 * fromIntegral b + fromIntegral a
extractNum _ = Nothing

display :: FilePath -> [(Int, Int)] -> IO ()
display path l = writeFile path (showStrings l)

showStrings :: [(Int, Int)] -> String
showStrings = concatMap format
  where
    format (a, b) = show a ++ " " ++ show b ++ "\n"

--findPath :: Maze -> (Int, Int) -> [(Int, Int)]
--findPath maze curr = 

findRPath :: Maze -> (Int, Int) -> (Int, Int) -> [(Int, Int)]
findRPath maze curr forbidden = case () of
    () | curr == (height maze, width maze) -> [(height maze, width maze)]
       | otherwise -> findRPath maze (head (possibleMoves maze curr forbidden)) curr

possibleMoves :: Maze -> (Int, Int) -> (Int, Int) -> [(Int, Int)]
possibleMoves m c f = canMoveDown m c f ++ canMoveRight m c f ++ canMoveUp m c f ++ canMoveLeft m c f

canMoveDown :: Maze -> (Int, Int) -> (Int, Int) -> [(Int, Int)]
canMoveDown maze curr forbidden =
    let arr = [] in
    if not $ isBotWallCell maze (fst curr + 1, snd curr) && not (getWallOnBottom (fst curr + 1) (snd curr) maze) && curr /= forbidden then
        arr
    else
        arr ++ [(fst curr + 1, snd curr)]

canMoveRight :: Maze -> (Int, Int) -> (Int, Int) -> [(Int, Int)]
canMoveRight maze curr forbidden =
    let arr = [] in
    if not $ isRightWallCell maze (fst curr, snd curr + 1) && not (getWallOnRight (fst curr) (snd curr + 1) maze) && curr /= forbidden then
        arr
    else
        arr ++ [(fst curr, snd curr + 1)]

canMoveUp :: Maze -> (Int, Int) -> (Int, Int) -> [(Int, Int)]
canMoveUp maze curr forbidden =
    let arr = [] in
    if not $ isTopWallCell maze (fst curr - 1, snd curr) && not (getWallOnTop (fst curr - 1) (snd curr) maze) && curr /= forbidden then
        arr
    else
        arr ++ [(fst curr - 1, snd curr)]

canMoveLeft :: Maze -> (Int, Int) -> (Int, Int) -> [(Int, Int)]
canMoveLeft maze curr forbidden =
    let arr = [] in
    if not $ isLeftWallCell maze (fst curr, snd curr - 1) && not (getWallOnLeft (fst curr) (snd curr - 1) maze) && curr /= forbidden then
        arr
    else
        arr ++ [(fst curr, snd curr - 1)]


isBotWallCell :: Maze -> (Int, Int) -> Bool
isBotWallCell maze (y, _) = (height maze == y) && True

isTopWallCell :: Maze -> (Int, Int) -> Bool
isTopWallCell maze (y, _) = (0 == y) && True

isLeftWallCell :: Maze -> (Int, Int) -> Bool
isLeftWallCell maze (_, x) = (0 == x) && True

isRightWallCell :: Maze -> (Int, Int) -> Bool
isRightWallCell maze (_, x) = (height maze == x) && True

getCell :: Int -> Int -> Maze -> Cell
getCell a b maze = cells maze!(a,b)

getWallOnBottom :: Int -> Int -> Maze -> Bool
getWallOnBottom a b maze = wallOnBottom $ getCell a b maze

getWallOnRight :: Int -> Int -> Maze -> Bool
getWallOnRight a b maze = wallOnRight $ getCell a b maze

getWallOnTop :: Int -> Int -> Maze -> Bool
getWallOnTop a b maze = wallOnBottom $ getCell (a-1) b maze

getWallOnLeft :: Int -> Int -> Maze -> Bool
getWallOnLeft a b maze = wallOnRight $ getCell a (b-1) maze

makeMaze :: Int -> Int -> [Word8] -> Maze
makeMaze h w bytes = do
    let twoDBitList = map (toBits8 . toInteger) bytes
    let bitListLong = concat twoDBitList
    let bitList = take (w*h*2) bitListLong
    let c = makeCells bitList
    Maze {height = h, width = w, cells = listArray ((0,0),(h,w)) c}

makeCells :: [Bool] -> [Cell]
makeCells [] = []
makeCells (k:v:t) = Cell { wallOnRight = k, wallOnBottom = v} : makeCells t

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