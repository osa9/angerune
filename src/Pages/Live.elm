module Pages.Live exposing (view)

import Array
import Components.RuneTree
import Dict exposing (Dict)
import Element as El
import Element.Background as Background
import Element.Border as Border
import Element.Events as Events
import Element.Font as Font
import Element.Input as Input
import List.Extra
import Model exposing (..)
import Models.RemoteData exposing (..)
import Models.Rune exposing (..)
import Theme
import Url
import Utils exposing (..)


view : Model -> El.Element Msg
view model =
    case ( model.rune, model.liveRunePage ) of
        ( Failure, _ ) ->
            El.text "error"

        ( Success rune, Just page ) ->
            El.column [ El.padding 30, El.spacing 20 ]
                [ liveBar model
                , Components.RuneTree.view rune page UpdateRunePage
                ]

        _ ->
            El.text "Loading"


liveBar : Model -> El.Element Msg
liveBar model =
    El.row [ El.spacing 5 ]
        [ liveButton model
        , Input.text [ Font.color (El.rgb255 0 0 0), Font.size 14, El.width (El.px 250) ] { onChange = always NoOp, text = liveUrl model, placeholder = Nothing, label = Input.labelHidden "Live URL" }
        ]


liveButton : Model -> El.Element Msg
liveButton model =
    case model.liveSession of
        Just s ->
            Input.button Theme.primary { onPress = Just EndLive, label = El.text "STOP" }

        _ ->
            Input.button Theme.primary { onPress = Just (StartLive Nothing), label = El.text "LIVE!" }


liveUrl : Model -> String
liveUrl model =
    let
        url =
            model.url
    in
    case model.liveSession of
        Just s ->
            Url.toString { url | path = "/live/" ++ s, query = Nothing, fragment = Nothing }

        Nothing ->
            "<-- Start live!"
