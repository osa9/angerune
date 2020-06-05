module Components.RuneTree exposing (..)

import Dict exposing (Dict)
import Array exposing (Array)
import List.Extra
import Element as El
import Element.Events as Events
import Element.Font as Font
import Element.Border as Border
import Element.Background as Background

import Model
import Models.Rune exposing (..)
import Utils exposing (..)


init : RunePage
init = {
    key = Nothing,
    name = "",
    description = "",
    rune = {
        mainRune = Just "Precision"
      , mainSelected = Array.repeat 4 Nothing
      , subRune = Just "Domination"
      , subSelected = []
      , shardsSelected = Array.repeat 3 Nothing
    }}

type Msg
    = SetMainRune String
    | SetMainSelected Int Int
    | SetSubRune String
    | SetSubSelected Int Int
    | SetShardsSelected Int Int


-- イベントをシンプルにする
update : RunePage -> (RunePage -> Model.Msg) -> Msg-> Model.Msg
update model toMsg msg =
    let rune = model.rune
    in case msg of
        SetMainRune key ->
            toMsg { model | rune = {rune | mainRune = Just key, mainSelected = Array.repeat 4 Nothing}}

        SetMainSelected row col ->
            let
                -- select or toggle item
                select : Array (Maybe a) -> Int -> a -> Array (Maybe a)
                select arr n newN =
                    arr
                        |> Array.set n
                            (if Array.get n arr == Just (Just newN) then
                                Nothing

                             else
                                Just newN
                            )
            in
                toMsg { model | rune = {rune | mainSelected = select rune.mainSelected row col }}

        SetSubRune key ->
            toMsg { model | rune = {rune | subRune = Just key, subSelected = [] }}


        SetSubSelected row col ->
            let
                select : Int -> Int -> SubSelected
                select index x =
                    if Maybe.map Tuple.first (List.head rune.subSelected) == Just index then
                        List.take 2 <| ( index, x ) :: Maybe.withDefault [] (List.tail rune.subSelected)

                    else
                        List.take 2 <| ( index, x ) :: Maybe.withDefault [] (Maybe.map (\h -> [ h ]) (List.head rune.subSelected))

            in toMsg { model | rune = {rune | subSelected = select row col }}


        SetShardsSelected row col ->
            let
                -- select or toggle item
                select : Array (Maybe a) -> Int -> a -> Array (Maybe a)
                select arr n newN =
                    arr
                        |> Array.set n
                            (if Array.get n arr == Just (Just newN) then
                                Nothing

                             else
                                Just newN
                            )

            in toMsg { model | rune = {rune | shardsSelected = select rune.shardsSelected row col }}



---- VIEW ----




view : Rune -> RunePage -> (RunePage -> Model.Msg) -> El.Element Model.Msg
view rune page toMsg =
    El.map (update page toMsg) <| viewRuneTree rune page.rune

viewRuneTree : Rune -> RunePageData -> El.Element Msg
viewRuneTree rune data =
    El.row []
        [ El.el [ El.width (El.px 450), El.alignTop ]
                            (showMainRune rune.runes data.mainRune data.mainSelected)
                        , El.column []
                            [ showSubRune rune.runes data.subRune data.subSelected
                            , showShards rune.shards data.shardsSelected
                            ]
                        ]

showMainRune : (List RunePath) -> Maybe String -> MainSelected -> El.Element Msg
showMainRune rune runeKey selected =
    El.column [El.alignTop]
        [ showRunePathList rune runeKey SetMainRune
        , showMainPath selected (List.Extra.find (\path -> case runeKey of
                         Just mainRune -> path.key == mainRune
                         Nothing -> False) rune)
                        ]

showSubRune : (List RunePath) -> Maybe String -> SubSelected -> El.Element Msg
showSubRune rune runeKey selected =
    El.column [El.alignTop]
        [ showRunePathList rune runeKey SetSubRune
        , showSubPath selected (List.Extra.find (\path -> case runeKey of
                         Just mainRune -> path.key == mainRune
                         Nothing -> False) rune)
                        ]

--| メインとサブのパス(栄華とか)選ぶやつ
showRunePathList : (List RunePath) -> Maybe String -> (String -> Msg) -> El.Element Msg
showRunePathList rune mainRune onSelect =
    let
        mainIcon : List (El.Attribute Msg)
        mainIcon =
            List.Extra.find (\path -> Just path.key == mainRune) rune
            |> Maybe.map (\path -> [Background.image path.icon])
            |> Maybe.withDefault []

        isMain : String -> Bool
        isMain key =
            case mainRune of
                Just mainKey ->
                    key == mainKey

                _ ->
                    False

        showRuneIcon : RunePath -> El.Element Msg
        showRuneIcon path =
            El.column
                (if isMain path.key then
                    [Events.onClick <| onSelect path.key, El.spacing 2]

                 else
                    [ className "gray", Events.onClick <| onSelect path.key, El.spacing 2]
                )
                [ El.image
                    [
                        El.width (El.px 30),
                        El.height (El.px 30),
                        Border.width 1,
                        Border.rounded 20,
                        El.padding 2,
                        Border.color <| if isMain path.key then
                        (Maybe.withDefault (El.rgb255 192 192 192)
                        <| Maybe.map (\s -> Maybe.withDefault (El.rgb255 192 192 192) (Dict.get s runeColors)) mainRune)
                        else (El.rgb255 192 192 192)

                    ]
                    { src = path.icon, description = path.name }
                , El.el [Font.size 11, El.centerX] <| El.text path.name
                ]

        color : El.Color
        color = Maybe.withDefault (El.rgb255 80 80 80) <| Maybe.map (\s -> Maybe.withDefault (El.rgb255 80 80 80) <| Dict.get s runeColors) mainRune
    in
    El.row
        []
        [
            El.el (mainIcon ++ [
                El.padding 5,
                El.width (El.px 60),
                El.height (El.px 60),
                Border.rounded 40,
                Border.width 2,
                El.alpha 0.6,
                Border.color color,
                Border.glow color 1
            ]) El.none,
            El.row [El.spacing 12, El.paddingEach {edges | left = 20}] (List.map showRuneIcon rune)
        ]

runeColors : Dict String El.Color
runeColors =
    Dict.fromList
        [
            ("Precision", El.rgb255 192 192 0),
            ("Domination", El.rgb255 255 40 20),
            ("Sorcery", El.rgb255 160 0 220),
            ("Resolve", El.rgb255 0 192 0),
            ("Inspiration", El.rgb255 0 192 192)
        ]


showMainPath : MainSelected -> Maybe RunePath -> El.Element Msg
showMainPath selected mainRune =

    case mainRune of
        Nothing ->
            El.el [] <| El.text "Not found"

        Just path ->
            let color = Maybe.withDefault (El.rgb255 40 40 40) (Dict.get path.key runeColors)
            in El.column [El.spacing 1]
               <| List.indexedMap (runeSelector color selected) (List.map .runes path.slots)

showSubPath : SubSelected -> Maybe RunePath -> El.Element Msg
showSubPath selected subRune =
    case subRune of
        Nothing ->
            El.el [] <| El.text "Not Found"

        Just path ->
            let color = Maybe.withDefault (El.rgb255 40 40 40) (Dict.get path.key runeColors)
            in El.column [El.spacing 1]
               <| List.indexedMap (subRuneSelector color selected)
               <| List.map .runes
               <| Maybe.withDefault []
               <| List.tail path.slots

runeSelector : El.Color -> MainSelected -> Int -> List RuneItem -> El.Element Msg
runeSelector color selected index runes =
    El.row [] <|
        [ El.column [El.width (El.px 60)] [
            El.el [ -- |
                El.centerX,
                El.width (El.px 0),
                El.height (El.px 61),
                Border.width 1,
                El.alpha 0.6,
                Border.color color,
                Border.glow color 1
            ] El.none
            ,El.el [ -- o
                El.centerX,
                El.width (El.px 20),
                El.height (El.px 20),
                Border.rounded 15,
                Border.width 2,
                El.alpha 0.6,
                Border.color color,
                Border.glow color 1,
                Background.color color
            ] El.none,
            if index /= 3 then El.el [ -- |
                El.centerX,
                El.width (El.px 0),
                El.height (El.px 61),
                Border.width 1,
                El.alpha 0.6,
                Border.color color,
                Border.glow color 1
            ] El.none else El.el [El.height (El.px 40)] El.none
          ]
          ,
          El.row
            [ El.paddingEach {edges | left = 10}, El.spacing 8]
            <| List.indexedMap (\col rune -> showRuneItem (Array.get index selected == Just (Just col)) (if index==0 then 82 else 52) SetMainSelected index col rune) runes
        ]

subRuneSelector : El.Color -> SubSelected -> Int -> List RuneItem -> El.Element Msg
subRuneSelector color selected index runes =
    El.row [] <|
        [ El.column [El.width (El.px 60)] [
            if index /= 2 then El.el [ -- |
                El.centerX,
                El.width (El.px 0),
                El.height (El.px 80),
                Border.width 1,
                El.alpha 0.6,
                Border.color color,
                Border.glow color 1
            ] El.none else El.none
            ,if index /= 2 then El.el [ -- o
                El.centerX,
                El.width (El.px 20),
                El.height (El.px 20),
                Border.rounded 15,
                Border.width 2,
                El.alpha 0.6,
                Border.color color,
                Border.glow color 1,
                Background.color color
            ] El.none else El.el [El.height (El.px 40)] El.none
          ]
          ,
          El.row
            [ El.paddingEach {edges | left = 10}, El.spacing 8]
            <| List.indexedMap (\col rune -> showRuneItem (List.length (List.filter (\r -> r == (index, col)) selected) > 0) 52 SetSubSelected index col rune) runes
        ]

--| ルーンアイコンを表示
showRuneItem : Bool -> Int -> (Int -> Int -> Msg) -> Int -> Int -> RuneItem -> El.Element Msg
showRuneItem isSelected iconSize onSelect index col item =
    El.column [] [
    El.column ([
          Events.onClick (onSelect index col)
        , className "runeStone"
        ] ++
        (if isSelected then [] else [className "gray"]))
        [ El.image [
            El.centerX,
            El.width (El.px iconSize),
            El.height (El.px iconSize)
        ] { src = item.icon, description = item.name }
        , El.el [Font.size 9, El.centerX] <| El.text item.name
        ]
        , El.el [className "runeDesc"] <| text2html item.longDesc
    ]

--| シャード(右下のやつ)を表示
showShards : Shards -> ShardsSelected -> El.Element Msg
showShards shards selected =
    El.column [El.spacing 1]
        <| List.indexedMap (shardsSelector selected)
        <| shards

shardsSelector : ShardsSelected -> Int -> List Shard -> El.Element Msg
shardsSelector selected index shards =
    let color = El.rgb255 128 128 100
    in El.row [] <|
        [ El.column [El.width (El.px 60)] [
            if index /= 0 then El.el [ -- |
                El.centerX,
                El.width (El.px 0),
                El.height (El.px 30),
                Border.width 1,
                El.alpha 0.6,
                Border.color color,
                Border.glow color 1
            ] El.none else El.el [El.height (El.px 40)] El.none
            ,El.el [ -- o
                El.centerX,
                El.width (El.px 20),
                El.height (El.px 20),
                Border.rounded 15,
                Border.width 2,
                El.alpha 0.6,
                Border.color color,
                Border.glow color 1,
                Background.color color
            ] El.none,
            if index /= 2 then El.el [ -- |
                El.centerX,
                El.width (El.px 0),
                El.height (El.px 40),
                Border.width 1,
                El.alpha 0.6,
                Border.color color,
                Border.glow color 1
            ] El.none else El.el [El.height (El.px 40)] El.none
          ]
          ,
          El.row
            [ El.paddingEach {edges | left = 10}, El.spacing 8]
            <| List.indexedMap (\col rune -> showRuneItem (Array.get index selected == Just (Just col)) 40 SetShardsSelected index col rune) shards
        ]

--| シャードのアイコンを表示
showShardItem : Bool -> Int -> (Int -> Int -> Msg) -> Int -> Int -> Shard -> El.Element Msg
showShardItem isSelected iconSize onSelect index col item =
    El.column ([
          Events.onClick (onSelect index col)
        ] ++
        (if isSelected then [] else [className "gray"]))
        [ El.image [
            El.centerX,
            El.width (El.px iconSize),
            El.height (El.px iconSize)
        ] { src = item.icon, description = item.name }
        , El.el [Font.size 9, El.centerX] <| El.text item.name
        ]

