module Pages.ChampionDB exposing (..)

import Components.SubHeader as SubHeader
import Data.ChampionTips exposing (getTips)
import Element as El
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Html exposing (Html)
import Html.Attributes as Attributes
import Model exposing (..)
import Models.Champion exposing (..)
import Models.RemoteData exposing (..)
import Models.Rune exposing (..)
import Round
import Table
import Utils exposing (..)


view : Model -> El.Element Msg
view model =
    case model.champions of
        NotAsked ->
            El.text "Loading"

        Loading ->
            El.text "Loading"

        Failure ->
            El.text "error"

        Success champions ->
            El.column [ El.width El.fill ]
                [ SubHeader.view
                , El.column [ El.padding 30 ]
                    [ El.text "ソート機能はまだない。。"
                    , showChampionsTable champions
                    ]
                ]


iconColumn : Table.Column Champion msg
iconColumn =
    Table.veryCustomColumn
        { name = ""
        , viewData = \c -> Table.HtmlDetails [] <| [ sprite c ]
        , sorter = Table.unsortable
        }


sprite : Champion -> Html msg
sprite champ =
    Html.div
        [ Attributes.href "/"
        , Attributes.style "z-index" "-100"
        , Attributes.style "width" <| String.fromInt champ.image.w ++ "px"
        , Attributes.style "height" <| String.fromInt champ.image.h ++ "px"
        , Attributes.style "background-image" ("url(" ++ champ.image.sprite ++ ")")
        , Attributes.style "background-position" ("-" ++ String.fromInt champ.image.x ++ "px -" ++ String.fromInt champ.image.y ++ "px")
        ]
        [ Html.text "" ]


tipsColumn : Table.Column Champion msg
tipsColumn =
    Table.veryCustomColumn
        { name = "メモ"
        , viewData = \c -> Table.HtmlDetails [] <| List.map (\s -> Html.div [] [ Html.text ("・" ++ s) ]) <| getTips c
        , sorter = Table.unsortable
        }


lv1 : Float -> Int
lv1 s =
    round s


lv18 : Float -> Float -> Int
lv18 s per =
    round <| s + per * 17


lv18as : Float -> Float -> String
lv18as s per =
    Round.round 3 <| s * (1 + 0.01 * per * 17)


config : Table.Config Champion Msg
config =
    Table.config
        { toId = .key
        , toMsg = \_ -> NoOp
        , columns =
            [ iconColumn
            , Table.stringColumn "学名" .id
            , Table.stringColumn "和名" .name
            , Table.stringColumn "種" (\c -> String.join ", " c.tags)
            , Table.intColumn "HP(Lv1)" (\c -> lv1 c.stats.hp)
            , Table.intColumn "HP(Lv18)" (\c -> lv18 c.stats.hp c.stats.hpPerLv)
            , Table.intColumn "AD(Lv1)" (\c -> lv1 c.stats.ad)
            , Table.intColumn "AD(Lv18)" (\c -> lv18 c.stats.ad c.stats.adPerLv)
            , Table.floatColumn "AS(Lv1)" (\c -> c.stats.ats)
            , Table.stringColumn "AS(Lv18)" (\c -> lv18as c.stats.ats c.stats.atsPerLv)
            , Table.intColumn "AR(Lv1)" (\c -> lv1 c.stats.ar)
            , Table.intColumn "AR(Lv18)" (\c -> lv18 c.stats.ar c.stats.arPerLv)
            , Table.intColumn "MR(Lv1)" (\c -> lv1 c.stats.mr)
            , Table.intColumn "MR(Lv18)" (\c -> lv18 c.stats.mr c.stats.mrPerLv)
            , tipsColumn
            ]
        }


showChampionsTable : Champions -> El.Element Msg
showChampionsTable champions =
    El.html <|
        Table.view config (Table.initialSort "ID") champions
