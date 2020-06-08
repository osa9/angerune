module Models.Rune exposing (..)

import Array exposing (Array)
import Json.Decode as D
import Json.Decode.Extra exposing (andMap)
import Json.Encode as E
import Url.Builder
import Utils exposing (nullable)



---- MODELS ----


type alias RunePage =
    { key : Maybe String
    , name : String
    , description : String
    , rune : RunePageData
    }


type alias RunePageData =
    { mainRune : Maybe String
    , mainSelected : MainSelected
    , subRune : Maybe String
    , subSelected : SubSelected
    , shardsSelected : ShardsSelected
    }


type alias MainSelected =
    Array (Maybe Int)


type alias ShardsSelected =
    Array (Maybe Int)


type alias SubSelected =
    List ( Int, Int )


type alias Rune =
    { shards : Shards
    , runes : List RunePath
    }


type alias RunePath =
    { id : Int
    , key : String
    , name : String
    , icon : String
    , slots : List RuneSlot
    }


type alias RuneSlot =
    { runes : List RuneItem
    }


type alias RuneItem =
    { id : Int
    , key : String
    , name : String
    , icon : String
    , longDesc : String
    , shortDesc : String
    }


type alias Shard =
    RuneItem


type alias Shards =
    List (List Shard)



---- SERIALIZE ----


toSnapshot : RunePage -> E.Value
toSnapshot page =
    E.object
        [ ( "key", nullable <| Maybe.map E.string page.key )
        , ( "name", E.string page.name )
        , ( "description", E.string page.description )
        , ( "rune"
          , E.object
                [ ( "main", nullable <| Maybe.map E.string page.rune.mainRune )
                , ( "mainSelected", E.array (\s -> nullable (Maybe.map E.int s)) <| page.rune.mainSelected )
                , ( "sub", nullable <| Maybe.map E.string page.rune.subRune )
                , ( "subSelected", E.list (\( a, b ) -> E.object [ ( "y", E.int a ), ( "x", E.int b ) ]) page.rune.subSelected )
                , ( "shardsSelected", E.array (\s -> nullable (Maybe.map E.int s)) <| page.rune.shardsSelected )
                ]
          )
        ]


fromSnapshot : String -> Result D.Error RunePage
fromSnapshot =
    D.decodeString <| runePageDecoder


fromSnapshots : String -> Result D.Error (List RunePage)
fromSnapshots =
    D.decodeString <| D.list runePageDecoder



---- PARSER ----


shards : String -> Shards
shards basePath =
    let
        mkPath : String -> String
        mkPath icon =
            Url.Builder.absolute [ basePath, "img", "perk-images", "StatMods", icon ] []

        adDesc =
            "+5.4 ADまたは+9 AP（アダプティブ）"

        asDesc =
            "+10% AS"

        cdrDesc =
            "+1～10% CDR（Lv1-18で増加）"

        arDesc =
            "+6 AR"

        mrDesc =
            "+8 MR"

        hpDesc =
            "+15～90 HP（Lv1-18で増加）"
    in
    [ [ { id = 10, key = "OffenseAdaptive", name = "アダプティブ", icon = mkPath "StatModsAdaptiveForceIcon.png", shortDesc = adDesc, longDesc = adDesc }
      , { id = 11, key = "OffenseAS", name = "攻撃速度", icon = mkPath "StatModsAttackSpeedIcon.png", shortDesc = asDesc, longDesc = asDesc }
      , { id = 12, key = "OffenseCDR", name = "クールダウン短縮", icon = mkPath "StatModsCDRScalingIcon.png", shortDesc = cdrDesc, longDesc = cdrDesc }
      ]
    , [ { id = 20, key = "FlexAdaptive", name = "アダプティブ", icon = mkPath "StatModsAdaptiveForceIcon.png", shortDesc = adDesc, longDesc = adDesc }
      , { id = 21, key = "FlexAR", name = "物理防御", icon = mkPath "StatModsArmorIcon.png", shortDesc = arDesc, longDesc = arDesc }
      , { id = 22, key = "FlexMR", name = "魔法防御", icon = mkPath "StatModsMagicResIcon.png", shortDesc = mrDesc, longDesc = mrDesc }
      ]
    , [ { id = 30, key = "DefenseHP", name = "体力", icon = mkPath "StatModsHealthScalingIcon.png", shortDesc = hpDesc, longDesc = hpDesc }
      , { id = 31, key = "DefenseAR", name = "物理防御", icon = mkPath "StatModsArmorIcon.png", shortDesc = arDesc, longDesc = arDesc }
      , { id = 32, key = "DefenseMR", name = "魔法防御", icon = mkPath "StatModsMagicResIcon.png", shortDesc = mrDesc, longDesc = mrDesc }
      ]
    ]


sortPath : D.Decoder (List { a | id : Int, key : String }) -> D.Decoder (List { a | id : Int, key : String })
sortPath =
    D.map <|
        List.sortBy
            (\a ->
                if a.key == "Inspiration" then
                    100000

                else
                    a.id
            )


runePageDecoder : D.Decoder RunePage
runePageDecoder =
    D.succeed RunePage
        |> andMap (D.nullable (D.field "key" D.string))
        |> andMap (D.field "name" D.string)
        |> andMap (D.field "description" D.string)
        |> andMap
            (D.field "rune"
                (D.map5 RunePageData
                    (D.field "main" (D.nullable D.string))
                    (D.field "mainSelected" (D.array <| D.nullable D.int))
                    (D.field "sub" (D.nullable D.string))
                    (D.field "subSelected" (D.list <| D.map2 (\a b -> ( a, b )) (D.field "y" D.int) (D.field "x" D.int)))
                    (D.field "shardsSelected" (D.array <| D.nullable D.int))
                )
            )


runeDecoder : String -> D.Decoder Rune
runeDecoder basePath =
    D.map2 Rune
        (D.succeed <| shards basePath)
        (sortPath <|
            D.list
                (D.map5 RunePath
                    (D.field "id" D.int)
                    (D.field "key" D.string)
                    (D.field "name" D.string)
                    (D.map (\icon -> Url.Builder.absolute [ basePath, "img", icon ] []) (D.field "icon" D.string))
                    (D.field "slots" (D.list <| slotDecoder basePath))
                )
        )


slotDecoder : String -> D.Decoder RuneSlot
slotDecoder basePath =
    D.field "runes" (D.map RuneSlot (D.list <| runeItemDecoder basePath))


runeItemDecoder : String -> D.Decoder RuneItem
runeItemDecoder basePath =
    D.map6 RuneItem
        (D.field "id" D.int)
        (D.field "key" D.string)
        (D.field "name" D.string)
        (D.map (\icon -> Url.Builder.absolute [ basePath, "img", icon ] []) (D.field "icon" D.string))
        (D.field "longDesc" D.string)
        (D.field "shortDesc" D.string)
