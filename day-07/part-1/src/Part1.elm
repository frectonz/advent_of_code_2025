module Part1 exposing (..)

import Browser
import Char exposing (Char)
import Html exposing (Html, h1, table, tbody, td, text, tr)
import Html.Attributes exposing (attribute)
import Input exposing (input)
import List.Extra exposing (getAt, setAt)



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
        ( splits, manifold ) =
            input |> toList |> processManifold
    in
    { title = "Advent of Code Day 07"
    , body =
        [ h1 [] [ text ("Split: " ++ String.fromInt splits) ]
        , viewManifold manifold
        ]
    }


viewManifold : Manifold -> Html msg
viewManifold manifold =
    table
        [ attribute "border" "0"
        , attribute "cellpadding" "4"
        , attribute "cellspacing" "0"
        ]
        [ tbody []
            (List.map viewRow manifold)
        ]


viewRow : List Char -> Html msg
viewRow row =
    tr []
        (List.map viewCell row)


viewCell : Char -> Html msg
viewCell c =
    td []
        [ text (String.fromChar c) ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



---


type alias Manifold =
    List (List Char)


toList : String -> Manifold
toList input =
    input |> String.lines |> List.map String.toList


placeAt : Char -> Int -> Int -> Manifold -> Manifold
placeAt cell row col =
    List.indexedMap
        (\i r ->
            if i == row then
                setAt col cell r

            else
                r
        )


cellAt : Int -> Int -> Manifold -> Maybe Char
cellAt row col manifold =
    manifold |> getAt row |> Maybe.andThen (getAt col)


processCell : ( Int, Int, Char ) -> ( Int, Manifold ) -> ( Int, Manifold )
processCell ( row, col, cell ) ( split, manifold ) =
    case cell of
        'S' ->
            ( split, placeAt '|' (row + 1) col manifold )

        '^' ->
            let
                isTachyonAbove =
                    cellAt (row - 1) col manifold |> Maybe.map (\c -> c == '|') |> Maybe.withDefault False
            in
            if isTachyonAbove then
                let
                    left =
                        cellAt row (col - 1) manifold
                in
                let
                    right =
                        cellAt row (col + 1) manifold
                in
                case ( left, right ) of
                    ( Just '|', Just '|' ) ->
                        ( split, manifold )

                    ( Just '|', _ ) ->
                        ( split + 1, manifold |> placeAt '|' row (col + 1) )

                    ( _, Just '|' ) ->
                        ( split + 1, manifold |> placeAt '|' row (col - 1) )

                    _ ->
                        ( split + 1, manifold |> placeAt '|' row (col + 1) |> placeAt '|' row (col - 1) )

            else
                ( split, manifold )

        '.' ->
            let
                isTachyonAbove =
                    cellAt (row - 1) col manifold |> Maybe.map (\c -> c == '|') |> Maybe.withDefault False
            in
            if isTachyonAbove then
                ( split, manifold |> placeAt '|' row col )

            else
                ( split, manifold )

        _ ->
            ( split, manifold )


processManifold : Manifold -> ( Int, Manifold )
processManifold manifold =
    manifold
        |> List.indexedMap
            (\i row ->
                row
                    |> List.indexedMap (\j cell -> ( i, j, cell ))
            )
        |> List.concat
        |> List.foldl processCell ( 0, manifold )
