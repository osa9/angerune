module Theme exposing (..)

import Element
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font


primary : List (Element.Attribute msg)
primary =
    [ Background.color <| Element.rgb255 63 81 181
    , Font.size 18
    , Border.rounded 4
    , Font.bold
    , Element.padding 10
    ]


secondary =
    Background.color (Element.rgb255 60 60 110)


black =
    Element.rgb255 32 32 32
