import Data.List as List
import Data.Maybe as Maybe
import Data.String as String
import Text.Read
import Debug.Trace

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

toOperation :: String -> Maybe Operation
toOperation "*" = Just Mul
toOperation "+" = Just Add
toOperation  _  = Nothing 

parseNumberLine :: String -> [Int]
parseNumberLine = Maybe.mapMaybe toInt . String.words

parseOperationLine :: String -> [Operation]
parseOperationLine = Maybe.mapMaybe toOperation . String.words

parseInput :: String -> ([Operation], [[Int]])
parseInput s =
  let lines = String.lines s in
  let linesCount = List.length lines in
  let operations = List.last lines in
  let numbers = take (linesCount - 1) lines in
  (parseOperationLine operations, List.map parseNumberLine numbers)

toColumns :: ([Operation], [[Int]]) -> [Column]
toColumns (operations, numbers) = 
  List.zipWith Column operations (transpose numbers)

solution :: [Column] -> Int
solution cols = sum $ List.map compute cols

main :: IO ()
main = do
  input <- readFile "inputs/input.txt"
  (print . solution . toColumns . parseInput) input

