module Part2

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

mapWithIndex : (Nat -> a -> b) -> List a -> List b
mapWithIndex f xs = go 0 xs
  where
    go : Nat -> List a -> List b
    go _ [] = []
    go i (x :: xs) = f i x :: go (S i) xs

filterWithIndex : (Nat -> a -> Bool) -> List a -> List a
filterWithIndex p xs = go 0 xs
  where
    go : Nat -> List a -> List a
    go _ [] = []
    go i (x :: xs) =
      if p i x
         then x :: go (S i) xs
         else      go (S i) xs

combineDigits : List Nat -> Nat
combineDigits xs = xs
  |> reverse
  |> mapWithIndex (\idx, x => x * (power 10 idx))
  |> sum


compareTuple : (Nat, Nat) -> (Nat, Nat) -> Ordering
compareTuple (i, x) (j, y) = if x == y then compare j i else compare x y

-- def solve_bank_part2(s):
--  if len(s) < 12:
--   return 0
--  r, i = [], -1
--  for k in range(12):
--   w = s[i+1:len(s)-12+k+1]
--   m = max(w)
--   i = i+1 + w.index(m)
--   r.append(m)
--
-- ​string maxJolt;
--  int n = s.size(),
--  k = 12;
--  for (int i = 0; i < n; i++) {
--   while (!maxJolt.empty() && maxJolt.back() < s[i] && (maxJolt.size() + (n - i)) > k) {
--     maxJolt.pop_back(); } if (maxJolt.size() < k) maxJolt.push_back(s[i]);
--   }
--  totalSum += stoll(maxJolt);

findLargestWithSuffix : Nat -> List Nat -> Nat
findLargestWithSuffix n xs =
  let len = length xs in
  if len > n then
    let
      -- We only care about the first (length - n) elements.
      -- Any element after this index will not have enough neighbors to the right.
      validCount = minus len n
      
      -- 'take' grabs the valid candidates
      candidates = take validCount xs
    in
      -- We fold over the candidates to find the max.
      -- We use 0 as the accumulator start because these are Nats.
      foldl max 0 candidates
  else
    0

-- findMaxSolution : List Nat -> Nat
-- findMaxSolution bank = 
--   combineDigits ((findLargestWithSuffix 12 bank) ::
--   (findLargestWithSuffix 11 bank) ::
--   (findLargestWithSuffix 10 bank) ::
--   (findLargestWithSuffix 9 bank) ::
--   (findLargestWithSuffix 8 bank) ::
--   (findLargestWithSuffix 7 bank) ::
--   (findLargestWithSuffix 6 bank) ::
--   (findLargestWithSuffix 5 bank) ::
--   (findLargestWithSuffix 4 bank) ::
--   (findLargestWithSuffix 3 bank) ::
--   (findLargestWithSuffix 2 bank) ::
--   (findLargestWithSuffix 1 bank) :: [])

splitAfter : Nat -> List Nat -> List Nat
splitAfter target [] = []
splitAfter target (x :: xs) =
  if x == target then xs
  else splitAfter target xs

findAndSlice : Nat -> List Nat -> Maybe (Nat, List Nat)
findAndSlice suffixNeeded bank =
  let len = length bank in
  if len <= suffixNeeded then 
    Nothing -- Impossible to pick a number and leave enough room
  else
    let
      -- We can only look at the first (len - suffixNeeded) items
      searchWindow = minus len suffixNeeded
      candidates = take searchWindow bank
      
      -- Find the largest number in that valid window
      maxVal = foldl max 0 candidates
      
      -- Slice the bank to use for the NEXT step
      newBank = splitAfter maxVal bank
    in
      Just (maxVal, newBank)

findMaxSolution : List Nat -> Nat
findMaxSolution initialBank = 
  case go 11 initialBank of
    Nothing => 0
    Just digitList => (combineDigits digitList)
  where
    go : Nat -> List Nat -> Maybe (List Nat)
    -- Base case: We finished the countdown (passed 0), so we stop.
    -- Note: We handle 0 inside the recursive step, so if we hit strict -1 (conceptually), we are done.
    -- Actually, simpler logic: verify count.
    
    go k bank = 
      -- Attempt to find a number that leaves 'k' items after it
      case findAndSlice k bank of
        Nothing => Nothing
        Just (foundDigit, slicedBank) => 
            if k == 0 then
                -- We are at the last digit, no more recursion needed
                Just [foundDigit]
            else
                -- We found a digit, now recurse with (k-1) and the SLICED bank
                case go (minus k 1) slicedBank of
                    Nothing => Nothing
                    Just rest => Just (foundDigit :: rest)

findSolution: String -> Nat
findSolution contents =
  contents
  |> parseInput
  |> map findMaxSolution
  |> sum

main : IO ()
main = do
  Right contents <- readFile "inputs/input.txt"
    | Left _ => printLn "Failed to read input"
  findSolution contents |> printLn
