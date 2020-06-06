module Route exposing (..)

import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, oneOf, s, string, top)


type Route
    = Home
    | Live (Maybe String)
    | RuneDB
    | ChampionDB (Maybe String)
    | Guide (Maybe String)


isLivePage : Maybe Route -> Bool
isLivePage r =
    case r of
        Just (Live _) ->
            True

        _ ->
            False


isDbPage : Maybe Route -> Bool
isDbPage r =
    case r of
        Just RuneDB ->
            True

        Just (ChampionDB _) ->
            True

        _ ->
            False


isGuidePage : Maybe Route -> Bool
isGuidePage r =
    case r of
        Just (Guide _) ->
            True

        _ ->
            False


isRuneDB : Maybe Route -> Bool
isRuneDB r =
    case r of
        Just RuneDB ->
            True

        _ ->
            False


isChampionDB : Maybe Route -> Bool
isChampionDB r =
    case r of
        Just (ChampionDB _) ->
            True

        _ ->
            False


parser : Parser (Route -> a) a
parser =
    oneOf
        [ Parser.map Home top
        , Parser.map (Live Nothing) (s "live") -- Live page default
        , Parser.map (\s -> Live (Just s)) (s "live" </> string) -- Live page with key
        , Parser.map RuneDB (s "runes") -- rune table
        , Parser.map (ChampionDB Nothing) (s "champions")
        , Parser.map (Guide Nothing) (s "guide") -- rune guide
        , Parser.map (\s -> Guide (Just s)) (s "guide" </> string) -- guide page
        ]


fromUrl : Url -> Maybe Route
fromUrl =
    Parser.parse parser
