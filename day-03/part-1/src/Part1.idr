module Part1

import System.File
import Data.String
import Data.Nat

charToNat : Char -> Maybe Nat
charToNat '0' = Just 0
charToNat '1' = Just 1
charToNat '2' = Just 2
charToNat '3' = Just 3
charToNat '4' = Just 4
charToNat '5' = Just 5
charToNat '6' = Just 6
charToNat '7' = Just 7
charToNat '8' = Just 8
charToNat '9' = Just 9
charToNat _ = Nothing

parseBank : List Char -> List Nat
parseBank chars = List.mapMaybe charToNat chars

parseInput: String -> List (List Nat)
parseInput str = unpack str |> Data.String.lines' |> map (parseBank)

combineDigits : (Nat, Nat) -> Nat
combineDigits (x, y) = (x * the Nat 10) + y

findMaxCombination : List (Nat, Nat) -> Nat
findMaxCombination list = list |> map combineDigits |> foldl (Nat.maximum) 0

generateCombinations : List Nat -> List (List (Nat, Nat))
generateCombinations lst =
  generateCombinations' lst []
  where
    generateCombinations' : List Nat -> List (List (Nat, Nat)) -> List (List (Nat, Nat))
    generateCombinations' [] result = reverse result
    generateCombinations' (hd :: tl) result = generateCombinations' tl ((combinations hd tl) :: result)
    where
      combinations : Nat -> List Nat -> List (Nat, Nat)
      combinations x ys = map (\y => (x, y)) ys

findMaxJoltageInBank: List Nat -> Nat
findMaxJoltageInBank bank =
  generateCombinations bank
  |> map (findMaxCombination)
  |> foldl (Nat.maximum) 0


findSolution: String -> Nat
findSolution contents =
  contents
  |> parseInput
  |> map findMaxJoltageInBank
  |> sum

main : IO ()
main = do
  Right contents <- readFile "inputs/input.txt"
    | Left _ => printLn "Failed to read input"
  findSolution contents |> printLn
