module Main exposing (..)

-- ルーン定義とJSONデコーダー
---- PORT ----

import Array exposing (Array)
import Browser
import Browser.Navigation as Nav
import Components.RuneTree
import Element as El
import Element.Background as Background
import Element.Font as Font
import Model exposing (..)
import Models.RemoteData exposing (..)
import Models.Rune exposing (..)
import Pages.ChampionDB
import Pages.Guide
import Pages.Live
import Pages.RuneDB
import Route exposing (..)
import Url
import Utils exposing (edges)


view : Model -> Browser.Document Msg
view model =
    { title = "AngeRune"
    , body =
        [ El.layout [ Font.color (El.rgb255 255 255 255) ] <|
            El.column [ El.width El.fill, El.height El.fill ]
                [ showHeader model
                , Maybe.withDefault El.none <| Maybe.map El.text model.error
                , route model
                ]
        ]
    }


route : Model -> El.Element Msg
route model =
    case model.route of
        Nothing ->
            El.text "Not Found!"

        Just Home ->
            Pages.Live.view model

        Just (Live _) ->
            Pages.Live.view model

        Just RuneDB ->
            Pages.RuneDB.view model

        Just (ChampionDB _) ->
            Pages.ChampionDB.view model

        Just (Guide _) ->
            Pages.Guide.view model


menuAttr : (Maybe Route -> Bool) -> Model -> List (El.Attribute msg)
menuAttr isSelf model =
    [ El.width (El.px 120), El.height El.fill, Font.size 16, Font.bold ]
        ++ (if isSelf model.route then
                [ Background.color (El.rgb255 70 70 110) ]

            else
                [ El.mouseOver [ Background.color (El.rgb255 70 70 110) ] ]
           )


showHeader : Model -> El.Element Msg
showHeader model =
    El.row
        [ El.width El.fill
        , El.height (El.px 48)
        , Background.color (El.rgb255 50 50 90)
        , El.paddingEach { edges | left = 40 }
        ]
        [ El.image [ El.width (El.px 32), El.height (El.px 32) ] { src = "/img/RunesIcon.png", description = "Rune Icon" }
        , El.el [] <| El.text "AngeRune"
        , El.el [ El.width (El.px 200) ] El.none
        , El.el (menuAttr isLivePage model) <|
            El.link [ El.centerX, El.centerY ] { url = "/live", label = El.text "Live" }
        , El.el (menuAttr isDbPage model) <| El.link [ El.centerX, El.centerY ] { url = "/runes", label = El.text "Database" }
        , El.el (menuAttr isGuidePage model) <| El.link [ El.centerX, El.centerY ] { url = "/guide", label = El.text "Guide" }
        , El.el [ El.alignRight, El.paddingXY 10 0, Font.color (El.rgb255 210 210 210), Font.size 14 ] <| El.text ("パッチ " ++ model.patch)
        ]



---- PROGRAM ----


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    let
        rt =
            fromUrl url

        patch =
            "10.10.3208608"

        -- SPAと非SPAで同じ処理が走るようにする
        ( model, msg ) =
            updateRoute url
                { key = key
                , url = url
                , liveRunePage = Just Components.RuneTree.init
                , shards = shards "dragontail"
                , route = rt
                , error = Nothing
                , rune = Loading
                , patch = patch
                , champions = Loading
                , liveSession = getSession rt
                , runePages = NotAsked
                , viewRune = NotAsked
                , editRune = Nothing
                }
    in
    ( model
    , Cmd.batch <|
        [ msg
        , getRunes "dragontail" patch "ja_JP"
        , getChampions "dragontail" patch "ja_JP"
        ]
    )


getSession : Maybe Route -> Maybe String
getSession r =
    case r of
        Just (Live (Just s)) ->
            Just s

        _ ->
            Nothing


subscription : Model -> Sub Msg
subscription model =
    Sub.batch
        [ receiveRune RuneReceived
        , liveStarted (\liveId -> LiveStarted liveId)
        , foundRunes FoundRunes
        , savedRune SavedEditRune
        , gotRune GotViewRune
        ]


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscription
        , onUrlRequest = LinkClicked
        , onUrlChange = UrlChanged
        }
