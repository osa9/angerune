module Pages.RuneDB exposing (view)

import Element as El
import Element.Border as Border
import Components.SubHeader as SubHeader
import Element.Font as Font
import Element.Background as Background
import Utils exposing (..)

import Model exposing (..)
import Models.Rune exposing (..)
import Models.RemoteData exposing (..)

view : Model -> El.Element Msg
view model =
    case model.rune of
        NotAsked ->
            El.text "Loading"

        Loading ->
            El.text "Loading"

        Failure ->
            El.text "error"

        Success rune ->
            El.column [ El.width El.fill] [
                SubHeader.view,
                showRuneTable rune
            ]


showRuneTable : Rune -> El.Element Msg
showRuneTable rune =
    El.column [El.padding 30, El.width (El.px 960), El.spacing 40 ] <| List.map showRunePath rune.runes


showRunePath : RunePath -> El.Element Msg
showRunePath path =
    El.column [El.spacing 10]
        [ El.row [
            El.width El.fill,
            Border.widthEach {edges | left=3, bottom =1},
            Border.color (El.rgb255 192 192 80),
            El.paddingEach {edges | left=10 }
          ]
          [ El.el [
              El.centerY,
              El.width (El.px 40),
              El.height (El.px 40)
            ] (El.image [] { src = path.icon, description = path.name}),
            El.el [El.centerY] (El.text path.name)
          ]
          , El.column [El.spacing 0]
              (List.indexedMap showRuneSlot path.slots)
        ]


showRuneSlot : Int -> RuneSlot -> El.Element Msg
showRuneSlot index slot =
    El.row [
        El.width El.fill,
        Border.width 1,
        Background.color (El.rgba255 64 32 32 0.8)
        ]
        [ El.el [
            El.width (El.px 120),
            El.height El.fill,
            Font.size 16
            ]
            (case index of
                0 ->
                    El.el [El.centerX, El.centerY] <| El.text "キーストーン"

                n ->
                    El.el [El.centerX, El.centerY] <| El.text ("スロット" ++ String.fromInt n))

        , El.column [
            El.width El.fill,
            Border.widthEach {edges | left=1}
            ] <| List.indexedMap showRuneItem slot.runes
        ]

showRuneItem : Int -> RuneItem -> El.Element Msg
showRuneItem index item =
    El.row ((if index /= 0 then [Border.widthEach {edges | top = 1}] else []) ++ [El.padding 10, El.spacing 10, El.width El.fill]) [
        El.column [El.width (El.px 120), Font.size 11] [
            El.image [El.width (El.px 80), El.height (El.px 80), El.centerX] { src = item.icon, description = item.name},
            El.el [El.centerX] (El.paragraph [] [El.text item.name])
        ],
        El.el [El.width El.fill, Font.size 14] <| El.paragraph [] [text2html item.longDesc]
    ]


