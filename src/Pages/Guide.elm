module Pages.Guide exposing (..)

import Components.RuneTree
import Element as El
import Element.Font as Font
import Element.Input as Input
import Model exposing (..)
import Models.RemoteData exposing (..)
import Models.Rune exposing (Rune, RunePage)
import Route
import Theme


view : Model -> El.Element Msg
view model =
    case ( model.rune, model.runePages ) of
        ( Failure, _ ) ->
            El.text "error"

        ( _, Failure ) ->
            El.text "error while loading query"

        _ ->
            El.row [ El.width El.fill, El.height El.fill ]
                [ showSidebar model.runePages
                , El.el [ El.padding 20, El.alignTop ] <|
                    case model.route of
                        Just (Route.Guide (Just "new")) ->
                            showEditRune model.rune (Maybe.withDefault Components.RuneTree.init model.editRune)

                        _ ->
                            showContent model
                ]


showContent : Model -> El.Element Msg
showContent model =
    case ( model.rune, model.viewRune ) of
        ( _, Failure ) ->
            El.text "ルーンの取得に失敗しました。"

        ( Failure, _ ) ->
            El.text "ルーンの取得に失敗しました。"

        ( Success rune, Success page ) ->
            showRunePage rune page

        _ ->
            El.text ""


showRunePage : Rune -> RunePage -> El.Element Msg
showRunePage rune page =
    El.column [ El.spacing 30 ]
        [ El.el [ Font.size 30, Font.bold ] <| El.text page.name
        , El.el [ Font.size 16 ] <| El.text page.description
        , Components.RuneTree.view rune page (always NoOp)
        ]


sidebar : List (El.Element Msg) -> El.Element Msg
sidebar =
    El.column [ El.height El.fill, El.width (El.px 300), Theme.secondary, El.padding 10 ]


showSidebar : RemoteData (List RunePage) -> El.Element Msg
showSidebar =
    Models.RemoteData.map
        (sidebar [ El.text "NotAsked" ])
        (sidebar [ El.text "Loading" ])
        (sidebar [ El.text "Failure" ])
        showSidebarContent


showSidebarContent : List RunePage -> El.Element Msg
showSidebarContent pages =
    let
        pageKeys =
            filterPageKey pages
    in
    El.column [ El.height El.fill, El.width (El.px 300), Theme.secondary, El.padding 10 ] <|
        [ El.el [ El.paddingXY 0 10 ] <| Input.button Theme.primary { onPress = Just NewRune, label = El.text "New" }
        ]
            ++ List.map (\( key, page ) -> El.el [] <| El.link [] { url = "/guide/" ++ key, label = El.text page.name }) pageKeys


filterPageKey : List RunePage -> List ( String, RunePage )
filterPageKey pages =
    List.filterMap
        (\page ->
            case page.key of
                Just key ->
                    Just ( key, page )

                Nothing ->
                    Just ( "???", page )
        )
        pages


showEditRune : RemoteData Rune -> RunePage -> El.Element Msg
showEditRune rune page =
    Models.RemoteData.map
        (El.text "NotAsked")
        (El.text "Loading")
        (El.text "Failure")
        (\r -> showEditRuneContent r page)
        rune


showEditRuneContent : Rune -> RunePage -> El.Element Msg
showEditRuneContent rune page =
    El.column [ El.spacing 20 ]
        [ El.row [ El.spacing 60 ]
            [ El.el [ El.width (El.px 400) ] <| Input.text [ Font.color Theme.black ] { onChange = \name -> UpdateEditRune { page | name = name }, text = page.name, placeholder = Nothing, label = Input.labelLeft [] (El.text "名前") }
            , El.el [] <|
                Input.button Theme.primary
                    { onPress =
                        if page.name /= "" && page.description /= "" then
                            Just SaveEditRune

                        else
                            Nothing
                    , label = El.text "保存"
                    }
            ]
        , El.el [ El.width (El.px 400) ] <| Input.multiline [ Font.color Theme.black, El.height (El.px 100) ] { onChange = \description -> UpdateEditRune { page | description = description }, text = page.description, placeholder = Nothing, label = Input.labelLeft [] (El.text "説明"), spellcheck = False }
        , Components.RuneTree.view rune page UpdateEditRune
        ]
