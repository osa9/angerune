module Utils exposing (..)

import Element exposing (Element)
import Html
import Html.Attributes
import Html.Parser
import Html.Parser.Util
import Json.Encode


edges =
    { top = 0
    , right = 0
    , bottom = 0
    , left = 0
    }


text2html : String -> Element msg
text2html htmlText =
    case Html.Parser.run htmlText of
        Ok nodes ->
            Element.html <| Html.div [] <| Html.Parser.Util.toVirtualDom nodes

        Err _ ->
            Element.none


className : String -> Element.Attribute msg
className name =
    Element.htmlAttribute <| Html.Attributes.class name


nullable : Maybe Json.Encode.Value -> Json.Encode.Value
nullable =
    Maybe.withDefault Json.Encode.null
