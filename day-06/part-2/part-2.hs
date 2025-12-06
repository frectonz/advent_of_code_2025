import Data.List as List
import Data.Maybe as Maybe
import Data.String as String
import Text.Read
import Debug.Trace
import Data.Char (isDigit, digitToInt)

data Operation = Mul | Add
  deriving Show

applyOp :: Operation -> (Int -> Int -> Int)
applyOp    Mul        = (*)
applyOp    Add        = (+)

baseAcc :: Operation -> Int
baseAcc    Mul        = 1
baseAcc    Add        = 0

data Column = Column Operation [Int]
  deriving Show

compute :: Column -> Int
compute (Column op nums) = foldl (applyOp op) (baseAcc op) nums

toInt :: String -> Maybe Int
toInt = readMaybe

toOperation :: Int -> Char -> Maybe (Int, Operation)
toOperation idx '*' = Just (idx, Mul)
toOperation idx '+' = Just (idx, Add)
toOperation _    _  = Nothing 

y :: Char -> Maybe Int
y x = Just (digitToInt x)

n :: Maybe Int
n = Nothing

isAllDigits :: String -> Bool
isAllDigits = all isDigit

parseNumberLine :: [Int] -> String -> [[Maybe Int]]
parseNumberLine indexes s = go [] s
  where
    isGroup :: String -> Bool
    isGroup []         = True
    isGroup [' ']      = True
    isGroup (' ' : tl) = elem (length s - length tl) indexes
    isGroup _          = False

    go :: [[Maybe Int]] -> String -> [[Maybe Int]]

    go acc (' '  : ' ' : ' ' : d   : tl) | isGroup tl && isAllDigits [d]          = go' ([n  , n  , n  , y d] : acc) tl
    go acc (' '  : ' ' : c   : d   : tl) | isGroup tl && isAllDigits [c, d]       = go' ([n  , n  , y c, y d] : acc) tl
    go acc (' '  : b   : c   : d   : tl) | isGroup tl && isAllDigits [b, c, d]    = go' ([n  , y b, y c, y d] : acc) tl
    go acc (a    : ' ' : ' ' : ' ' : tl) | isGroup tl && isAllDigits [a]          = go' ([y a, n  , n  , n  ] : acc) tl
    go acc (a    : b   : ' ' : ' ' : tl) | isGroup tl && isAllDigits [a, b]       = go' ([y a, y b, n  , n  ] : acc) tl
    go acc (a    : b   : c   : ' ' : tl) | isGroup tl && isAllDigits [a, b, c]    = go' ([y a, y b, y c, n  ] : acc) tl
    go acc (a    : b   : c   : d   : tl) | isGroup tl && isAllDigits [a, b, c, d] = go' ([y a, y b, y c, y d] : acc) tl

    go acc (' '  : ' ' : c   : tl) | isGroup tl && isAllDigits [c]       = go' ([n  , n  , y c] : acc) tl
    go acc (a    : ' ' : ' ' : tl) | isGroup tl && isAllDigits [a]       = go' ([y a, n  , n  ] : acc) tl
    go acc (' '  : b   : c   : tl) | isGroup tl && isAllDigits [b, c]    = go' ([n  , y b, y c] : acc) tl
    go acc (a    : b   : ' ' : tl) | isGroup tl && isAllDigits [a, b]    = go' ([y a, y b, n  ] : acc) tl
    go acc (a    : b   : c   : tl) | isGroup tl && isAllDigits [a, b, c] = go' ([y a, y b, y c] : acc) tl

    go acc (' '  : b   : tl) | isGroup tl && isAllDigits [b]    = go' ([n  , y b] : acc) tl
    go acc (a    : ' ' : tl) | isGroup tl && isAllDigits [a]    = go' ([y a, n  ] : acc) tl
    go acc (a    : b   : tl) | isGroup tl && isAllDigits [a, b] = go' ([y a, y b] : acc) tl

    go acc _ = acc

    go' acc []         = reverse acc
    go' acc (' ' : tl) = go acc tl
    go' acc _          = reverse acc


combineDigits :: [Maybe Int] -> Int
combineDigits = 
  sum . mapWithIndex (\idx x -> x * (10 ^ idx)) . reverse . catMaybes
  where
    mapWithIndex :: (Int -> Int -> Int) -> [Int] -> [Int]
    mapWithIndex f xs = go 0 xs
      where
        go :: Int -> [Int] -> [Int]
        go _ [] = []
        go i (x : xs) = f i x : go (i + 1) xs

parseNumbers :: [String] -> [Int] -> [[Int]]
parseNumbers numbers indexes =
  map (map combineDigits. transpose)
  $ transpose
  $ List.map (parseNumberLine indexes) numbers

parseOperationLine :: String -> ([Int], [Operation])
parseOperationLine = unzip . catMaybes . mapWithIndex toOperation
  where
    mapWithIndex f xs = go 0 xs
      where
        go _ [] = []
        go i (x : xs) = f i x : go (i + 1) xs

parseInput :: String -> ([Operation], [[Int]])
parseInput s =
  let lines = String.lines s in
  let linesCount = List.length lines in
  let operations = List.last lines in
  let numbers = take (linesCount - 1) lines in
  let (indexes, ops) = parseOperationLine operations in
  (ops, parseNumbers numbers indexes)

toColumns :: ([Operation], [[Int]]) -> [Column]
toColumns (operations, numbers) = 
  List.zipWith Column operations numbers

solution :: [Column] -> Int
solution cols = sum $ List.map compute cols

main :: IO ()
main = do
  input <- readFile "inputs/input.txt"
  (print . solution . toColumns . parseInput) input
