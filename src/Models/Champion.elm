module Models.Champion exposing (..)

import Array exposing (Array)
import Dict exposing (Dict)
import Json.Decode as D
import Json.Decode.Extra exposing (andMap)
import Url.Builder


type alias Champions =
    List Champion


type alias Champion =
    { id : String
    , key : String
    , name : String
    , title : String
    , blurb : String
    , image : ChampionImage
    , tags : List String
    , partype : String
    , stats : ChampionStats
    }


type alias ChampionStats =
    { hp : Float
    , hpPerLv : Float
    , hpRegen : Float
    , hpRegenPerLv : Float
    , mp : Float
    , mpPerLv : Float
    , mpRegen : Float
    , mpRegenPerLv : Float
    , moveSpeed : Float
    , ar : Float
    , arPerLv : Float
    , mr : Float
    , mrPerLv : Float
    , crit : Float
    , critPerLv : Float
    , ad : Float
    , adPerLv : Float
    , ats : Float
    , atsPerLv : Float
    }


type alias ChampionImage =
    { full : String
    , sprite : String
    , group : String
    , x : Int
    , y : Int
    , w : Int
    , h : Int
    }


championsDecoder : String -> D.Decoder Champions
championsDecoder basePath =
    D.map Dict.values <|
        D.field "data" <|
            D.dict <|
                championDecoder basePath


championDecoder : String -> D.Decoder Champion
championDecoder basePath =
    D.succeed Champion
        |> andMap (D.field "id" D.string)
        |> andMap (D.field "key" D.string)
        |> andMap (D.field "name" D.string)
        |> andMap (D.field "title" D.string)
        |> andMap (D.field "blurb" D.string)
        |> andMap (D.field "image" <| championImageDecoder basePath)
        |> andMap (D.field "tags" (D.list D.string))
        |> andMap (D.field "partype" D.string)
        |> andMap (D.field "stats" championStatDecoder)


championImageDecoder : String -> D.Decoder ChampionImage
championImageDecoder basePath =
    D.succeed ChampionImage
        |> andMap (D.map (\img -> Url.Builder.absolute [ basePath, "img", "champion", img ] []) (D.field "full" D.string))
        |> andMap (D.map (\img -> Url.Builder.absolute [ basePath, "img", "sprite", img ] []) (D.field "sprite" D.string))
        |> andMap (D.field "group" D.string)
        |> andMap (D.field "x" D.int)
        |> andMap (D.field "y" D.int)
        |> andMap (D.field "w" D.int)
        |> andMap (D.field "h" D.int)


championStatDecoder : D.Decoder ChampionStats
championStatDecoder =
    D.succeed ChampionStats
        |> andMap (D.field "hp" D.float)
        |> andMap (D.field "hpperlevel" D.float)
        |> andMap (D.field "hpregen" D.float)
        |> andMap (D.field "hpregenperlevel" D.float)
        |> andMap (D.field "mp" D.float)
        |> andMap (D.field "mpperlevel" D.float)
        |> andMap (D.field "mpregen" D.float)
        |> andMap (D.field "mpregenperlevel" D.float)
        |> andMap (D.field "movespeed" D.float)
        |> andMap (D.field "armor" D.float)
        |> andMap (D.field "armorperlevel" D.float)
        |> andMap (D.field "spellblock" D.float)
        |> andMap (D.field "spellblockperlevel" D.float)
        |> andMap (D.field "crit" D.float)
        |> andMap (D.field "critperlevel" D.float)
        |> andMap (D.field "attackdamage" D.float)
        |> andMap (D.field "attackdamageperlevel" D.float)
        |> andMap (D.field "attackspeed" D.float)
        |> andMap (D.field "attackspeedperlevel" D.float)
