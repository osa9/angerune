module Components.SubHeader exposing (..)

import Element as El
import Element.Background as Background
import Model exposing (..)
import Route exposing (..)
import Utils exposing (..)


menuAttr : (Maybe Route -> Bool) -> Model -> List (El.Attribute msg)
menuAttr isSelf model =
    [ El.width (El.px 120), El.height El.fill ]
        ++ (if isSelf model.route then
                [ Background.color (El.rgb255 70 70 140) ]

            else
                [ El.mouseOver [ Background.color (El.rgb255 70 70 140) ] ]
           )


view : Model -> El.Element Msg
view model =
    El.row
        [ El.width El.fill
        , El.height (El.px 40)
        , Background.color (El.rgb255 60 60 110)
        , El.paddingEach { edges | left = 40 }
        ]
        [ El.el (menuAttr isRuneDB model) <| El.link [ El.centerX, El.centerY ] { url = "/runes", label = El.text "Rune" }
        , El.el (menuAttr isChampionDB model) <| El.link [ El.centerX, El.centerY ] { url = "/champions", label = El.text "Champion" }

        --, El.el [ El.width (El.px 100) ] <| El.link [ El.centerX ] { url = "/db/items", label = El.text "Items" }
        ]
