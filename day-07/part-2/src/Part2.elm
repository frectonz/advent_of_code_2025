module Part2 exposing (..)

import Browser
import Char exposing (Char)
import Dict exposing (Dict)
import Example exposing (input)
import Html exposing (Html, div, h1, hr, table, tbody, td, text, tr)
import Html.Attributes exposing (attribute)
import List exposing (all, drop, member)
import List.Extra exposing (count, getAt, setAt)



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
        timelines =
            input |> toList |> processManifold
    in
    { title = "Advent of Code Day 07"
    , body =
        [ h1 [] [ text ("Manifolds: " ++ (timelines |> List.length |> String.fromInt)) ]
        , viewManifolds timelines
        ]
    }


viewManifolds : List Manifold -> Html msg
viewManifolds manifolds =
    div [] (List.map (\x -> div [] [ hr [] [], viewManifold x ]) manifolds)


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


type alias GetCellCache =
    Dict ( Int, Int ) (Maybe Char)


toList : String -> Manifold
toList input =
    input |> String.trim |> String.lines |> List.map String.toList


cellAt : Int -> Int -> GetCellCache -> Manifold -> ( Maybe Char, GetCellCache )
cellAt row col cache manifold =
    case Dict.get ( row, col ) cache of
        Just x ->
            ( x, cache )

        Nothing ->
            let
                val =
                    manifold |> getAt row |> Maybe.andThen (getAt col)

                newCache =
                    Dict.insert ( row, col ) val cache
            in
            ( val, newCache )


placeAt : Char -> Int -> Int -> GetCellCache -> Manifold -> ( Maybe Manifold, GetCellCache )
placeAt cell row col cache manifold =
    case cellAt row col cache manifold of
        ( Just '.', x ) ->
            ( Just
                (List.indexedMap
                    (\i r ->
                        if i == row then
                            setAt col cell r

                        else
                            r
                    )
                    manifold
                )
            , x
            )

        _ ->
            ( Nothing, cache )


processCell : Manifold -> ( Int, Int, Char ) -> ( GetCellCache, List (Maybe Manifold) ) -> ( GetCellCache, List (Maybe Manifold) )
processCell manifold ( row, col, cell ) ( cache, acc ) =
    case cell of
        'S' ->
            let
                ( newManifold, newCache ) =
                    placeAt '|' (row + 1) col cache manifold
            in
            ( newCache, newManifold :: acc )

        '^' ->
            let
                ( above, cache1 ) =
                    cellAt (row - 1) col cache manifold

                isTachyonAbove =
                    above
                        |> Maybe.map (\c -> c == '|')
                        |> Maybe.withDefault False
            in
            if isTachyonAbove then
                let
                    ( left, cache2 ) =
                        cellAt row (col - 1) cache1 manifold
                in
                let
                    ( right, cache3 ) =
                        cellAt row (col + 1) cache2 manifold
                in
                case ( left, right ) of
                    ( Just '|', Just '|' ) ->
                        ( cache3, Just manifold :: acc )

                    ( Just '|', _ ) ->
                        let
                            ( newManifold, newCache ) =
                                placeAt '|' row (col + 1) cache3 manifold
                        in
                        ( newCache, newManifold :: acc )

                    ( _, Just '|' ) ->
                        let
                            ( newManifold, newCache ) =
                                placeAt '|' row (col - 1) cache3 manifold
                        in
                        ( newCache, newManifold :: acc )

                    _ ->
                        let
                            ( newManifoldRight, newCache1 ) =
                                placeAt '|' row (col + 1) cache3 manifold

                            ( newManifoldLeft, newCache2 ) =
                                placeAt '|' row (col - 1) newCache1 manifold
                        in
                        ( newCache2, newManifoldRight :: newManifoldLeft :: acc )

            else
                ( cache, acc )

        '.' ->
            let
                ( above, cache1 ) =
                    cellAt (row - 1) col cache manifold

                isTachyonAbove =
                    above |> Maybe.map (\c -> c == '|') |> Maybe.withDefault False
            in
            if isTachyonAbove then
                let
                    ( newManifold, newCache ) =
                        placeAt '|' row col cache1 manifold
                in
                ( newCache, newManifold :: acc )

            else
                ( cache, acc )

        _ ->
            ( cache, acc )


hasEnded : Manifold -> Bool
hasEnded manifold =
    manifold
        |> drop 1
        |> all (member '|')


isValid : Manifold -> Bool
isValid manifold =
    manifold
        |> drop 1
        |> all (\row -> count ((==) '|') row <= 1)


processManifold : Manifold -> List Manifold
processManifold manifold =
    if hasEnded manifold then
        [ manifold ]

    else
        let
            manifolds =
                manifold
                    |> List.indexedMap
                        (\i row ->
                            row
                                |> List.indexedMap (\j cell -> ( i, j, cell ))
                        )
                    |> List.concat
                    |> List.foldl (processCell manifold) ( Dict.empty, [] )
                    |> Tuple.second
                    |> List.filterMap identity
                    |> List.filter isValid
                    |> List.Extra.unique
        in
        if all hasEnded manifolds then
            manifolds

        else
            manifolds
                |> List.map processManifold
                |> List.concat
