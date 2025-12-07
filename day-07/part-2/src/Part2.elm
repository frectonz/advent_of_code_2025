module Part2 exposing (..)

import Browser
import Char exposing (Char)
import Dict exposing (Dict)
import Html exposing (h1, text)
import Input exposing (input)
import List exposing (drop, head)
import List.Extra exposing (getAt)



-- MAIN


main : Program () Model Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    {}


init : () -> ( Model, Cmd msg )
init _ =
    ( Model, Cmd.none )



-- UPDATE


type Msg
    = NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )



-- VIEW


view : Model -> Browser.Document Msg
view _ =
    let
        ( pos, manifold ) =
            input |> toList

        timelines =
            processManifold pos manifold
    in
    { title = "Advent of Code Day 07"
    , body =
        [ h1 [] [ text ("Manifolds: " ++ (timelines |> String.fromInt)) ]
        ]
    }



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



---


type alias Manifold =
    List (List Char)


toList : String -> ( ( Int, Int ), Manifold )
toList input =
    let
        manifold =
            input |> String.trim |> String.lines |> List.map String.toList |> drop 1

        middle =
            manifold
                |> head
                |> Maybe.map
                    (\r ->
                        let
                            width =
                                List.length r
                        in
                        (width - 1) // 2
                    )
                |> Maybe.withDefault 0
    in
    ( ( 0, middle ), manifold )


cellAt : Int -> Int -> Manifold -> Maybe Char
cellAt row col manifold =
    manifold |> getAt row |> Maybe.andThen (getAt col)


cellBelow : Int -> Int -> Manifold -> Maybe Char
cellBelow row col =
    cellAt (row + 1) col



-- processManifold : ( Int, Int ) -> Manifold -> Int
-- processManifold ( row, col ) manifold =
--     case cellBelow row col manifold of
--         Just '.' ->
--             processManifold ( row + 1, col ) manifold
--         Just '^' ->
--             processManifold ( row + 1, col - 1 ) manifold + processManifold ( row + 1, col + 1 ) manifold
--         _ ->
--             1


type alias Memo =
    Dict ( Int, Int ) Int


processManifold : ( Int, Int ) -> Manifold -> Int
processManifold pos manifold =
    process pos manifold Dict.empty |> Tuple.first


process : ( Int, Int ) -> Manifold -> Memo -> ( Int, Memo )
process ( row, col ) manifold memo =
    case Dict.get ( row, col ) memo of
        Just cached ->
            ( cached, memo )

        Nothing ->
            let
                resultAndMemo =
                    case cellBelow row col manifold of
                        Just '.' ->
                            process ( row + 1, col ) manifold memo

                        Just '^' ->
                            let
                                ( left, memo1 ) =
                                    process ( row + 1, col - 1 ) manifold memo

                                ( right, memo2 ) =
                                    process ( row + 1, col + 1 ) manifold memo1
                            in
                            ( left + right, memo2 )

                        _ ->
                            ( 1, memo )
            in
            let
                ( result, memoUpdated ) =
                    resultAndMemo

                memoFinal =
                    Dict.insert ( row, col ) result memoUpdated
            in
            ( result, memoFinal )
