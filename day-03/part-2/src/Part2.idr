module Part2

import System.File
import Data.String
import Data.Nat
import Debug.Trace

record BatteryBank where
  constructor MkBatteryBank
  power : Nat

Show BatteryBank where
  show (MkBatteryBank power) = show power

BatteryBanks = List BatteryBank
Input = List BatteryBanks

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

mapWithIndex : (Nat -> a -> b) -> List a -> List b
mapWithIndex f xs = go 0 xs
  where
    go : Nat -> List a -> List b
    go _ [] = []
    go i (x :: xs) = f i x :: go (S i) xs

parseBank : List Char -> BatteryBanks
parseBank chars = chars |> List.mapMaybe charToNat |> mapWithIndex (\idx, x => MkBatteryBank x)

parseInput: String -> Input
parseInput str = unpack str |> Data.String.lines' |> map parseBank

combineDigits : List Nat -> Nat
combineDigits xs = xs
  |> reverse
  |> mapWithIndex (\idx, x => x * (power 10 idx))
  |> sum

splitAfter : Nat -> BatteryBanks -> BatteryBanks
splitAfter target [] = []
splitAfter target (((MkBatteryBank x)) :: xs) =
  if x == target then xs
  else splitAfter target xs

maxBatteryBank : BatteryBank -> BatteryBank -> BatteryBank
maxBatteryBank (MkBatteryBank x) (MkBatteryBank y) = if x > y then (MkBatteryBank x) else (MkBatteryBank y)

findMax: Nat -> BatteryBanks -> (Nat, BatteryBanks)
findMax suffixNeeded banks =
  let
    len = length banks
    searchWindow = len `minus` suffixNeeded
    MkBatteryBank maxBank = banks
        |> take searchWindow
        |> foldl maxBatteryBank (MkBatteryBank 0)

    newBanks = splitAfter maxBank banks
  in
    (maxBank, newBanks)

findMaxBatteryBank : BatteryBanks -> Nat
findMaxBatteryBank banks =
  let
    (one,    banks) = findMax 11 banks
    (two,    banks) = findMax 10 banks
    (three,  banks) = findMax 9  banks
    (four,   banks) = findMax 8  banks
    (five,   banks) = findMax 7  banks
    (six,    banks) = findMax 6  banks
    (seven,  banks) = findMax 5  banks
    (eight,  banks) = findMax 4  banks
    (nine,   banks) = findMax 3  banks
    (ten,    banks) = findMax 2  banks
    (eleven, banks) = findMax 1  banks
    (twelve, banks) = findMax 0  banks
  in
  combineDigits [one, two, three, four, five, six, seven, eight, nine, ten, eleven, twelve]

findSolution: String -> Nat
findSolution contents =
  contents
  |> parseInput
  |> map findMaxBatteryBank
  |> sum

main : IO ()
main = do
  Right contents <- readFile "inputs/input.txt"
    | Left _ => printLn "Failed to read input"
  findSolution contents |> printLn
