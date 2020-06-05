module Components.SubHeader exposing (..)

import Element as El
import Element.Background as Background
import Model exposing (..)
import Utils exposing (..)


view : El.Element Msg
view =
    El.row
        [ El.width El.fill
        , El.height (El.px 40)
        , Background.color (El.rgb255 60 60 110)
        , El.paddingEach { edges | left = 40 }
        , El.spacing 2
        ]
        [ El.el [ El.width (El.px 100) ] <| El.link [ El.centerX ] { url = "/runes", label = El.text "Rune" }
        , El.el [ El.width (El.px 100) ] <| El.link [ El.centerX ] { url = "/champions", label = El.text "Champion" }

        --, El.el [ El.width (El.px 100) ] <| El.link [ El.centerX ] { url = "/db/items", label = El.text "Items" }
        ]
