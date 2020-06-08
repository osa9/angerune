port module Model exposing (..)

-- ルーン定義とJSONデコーダー

import Array exposing (Array)
import Browser
import Browser.Navigation as Nav
import Http
import Json.Decode as D
import Json.Encode as E
import List.Extra
import Models.Champion
import Models.RemoteData exposing (..)
import Models.Rune exposing (..)
import Random
import Random.Char
import Random.String
import Route exposing (..)
import Table
import Task exposing (Task)
import Url
import Url.Builder
import Utils exposing (..)



---- PORT ----


port sendRune : E.Value -> Cmd msg


port startLive : E.Value -> Cmd msg


port subscribe : String -> Cmd msg


port liveStarted : (String -> msg) -> Sub msg


port receiveRune : (String -> msg) -> Sub msg


port unsubscribe : () -> Cmd msg


port findRunes : () -> Cmd msg


port foundRunes : (String -> msg) -> Sub msg


port getRune : String -> Cmd msg


port gotRune : (String -> msg) -> Sub msg


port saveRune : E.Value -> Cmd msg


port savedRune : (String -> msg) -> Sub msg



---- MODELS ----
--(Maybe (Int, Int), Maybe (Int, Int))


type alias Model =
    { key : Nav.Key
    , url : Url.Url
    , route : Maybe Route
    , error : Maybe String
    , patch : String
    , rune : RemoteData Rune
    , champions : RemoteData Models.Champion.Champions
    , shards : Shards
    , liveRunePage : Maybe RunePage
    , liveSession : Maybe String
    , runePages : RemoteData (List RunePage)
    , viewRune : RemoteData RunePage
    , editRune : Maybe RunePage
    , tableState : Table.State
    }


getRunes : String -> String -> String -> Cmd Msg
getRunes basePath version locale =
    Http.get
        { url = Url.Builder.absolute [ basePath, version, "data", locale, "runesReforged.json" ] []
        , expect = Http.expectJson GotRune (runeDecoder basePath)
        }


getChampions : String -> String -> String -> Cmd Msg
getChampions basePath version locale =
    Http.get
        { url = Url.Builder.absolute [ basePath, version, "data", locale, "champion.json" ] []
        , expect = Http.expectJson GotChampions (Models.Champion.championsDecoder basePath version)
        }



---- UPDATE ----


type Msg
    = NoOp
      -- Routing
    | LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
      -- Rune
    | GotRune (Result Http.Error Rune)
    | RuneReceived String
      -- Live
    | UpdateRunePage RunePage
    | StartLive (Maybe String)
    | LiveStarted String
    | JoinLive String
    | EndLive
      -- Champion
    | GotChampions (Result Http.Error Models.Champion.Champions)
    | SetError String
    | SetTableState Table.State
      -- Guide
    | FindRunes
    | FoundRunes String
    | SetViewRune RunePage
    | UpdateEditRune RunePage
    | SaveEditRune
    | SavedEditRune String
    | NewRune
    | GotViewRune String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        SetError error ->
            ( { model | error = Just error }, Cmd.none )

        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChanged url ->
            updateRoute url model

        GotRune result ->
            case result of
                Ok rune ->
                    ( { model | rune = Success rune }, Cmd.none )

                Err _ ->
                    ( { model | rune = Failure }, Cmd.none )

        GotChampions result ->
            case result of
                Ok champions ->
                    ( { model | champions = Success champions }, Cmd.none )

                Err _ ->
                    ( { model | champions = Failure }, Cmd.none )

        UpdateRunePage page ->
            let
                newModel =
                    { model | liveRunePage = Just page }
            in
            case model.liveSession of
                Just _ ->
                    ( newModel, sendRune <| Models.Rune.toSnapshot page )

                _ ->
                    ( newModel, Cmd.none )

        RuneReceived s ->
            case Models.Rune.fromSnapshot s of
                Err _ ->
                    ( { model | error = Just "Rune parse error" }, Cmd.none )

                Ok runePage ->
                    ( { model | liveRunePage = Just runePage }
                    , Cmd.none
                    )

        StartLive live ->
            case ( live, model.liveRunePage ) of
                ( _, Just page ) ->
                    ( model, startLive (toSnapshot page) )

                _ ->
                    ( model, Cmd.none )

        LiveStarted liveId ->
            case model.liveRunePage of
                Just page ->
                    ( { model | liveRunePage = Just { page | key = Just liveId }, liveSession = Just liveId }, subscribe liveId )

                _ ->
                    ( model, Cmd.none )

        JoinLive liveId ->
            ( { model | liveSession = Just liveId }, subscribe liveId )

        EndLive ->
            case model.liveRunePage of
                Just page ->
                    ( { model | liveSession = Nothing, liveRunePage = Just { page | key = Nothing } }, unsubscribe () )

                _ ->
                    ( { model | liveSession = Nothing }, unsubscribe () )

        FindRunes ->
            case model.runePages of
                Loading ->
                    ( model, Cmd.none )

                Failure ->
                    ( model, Cmd.none )

                _ ->
                    ( { model | runePages = Loading }, findRunes () )

        FoundRunes s ->
            case Models.Rune.fromSnapshots s of
                Err errMsg ->
                    ( { model | error = Just ("Query Error: " ++ D.errorToString errMsg), runePages = Failure }, Cmd.none )

                Ok pages ->
                    ( { model | runePages = Success pages }, Cmd.none )

        SetViewRune page ->
            ( { model | viewRune = Success page }, Cmd.none )

        UpdateEditRune page ->
            ( { model | editRune = Just page }, Cmd.none )

        SaveEditRune ->
            case model.editRune of
                Just rune ->
                    ( model, saveRune <| Models.Rune.toSnapshot rune )

                _ ->
                    ( { model | error = Just "edit rune is nothing" }, Cmd.none )

        SavedEditRune pageId ->
            ( model, Nav.pushUrl model.key <| "/guide/" ++ pageId )

        NewRune ->
            ( { model | editRune = Nothing }, Nav.pushUrl model.key <| "/guide/new" )

        GotViewRune s ->
            case Models.Rune.fromSnapshot s of
                Err errMsg ->
                    ( { model | error = Just ("Query Error: " ++ D.errorToString errMsg), viewRune = Failure }, Cmd.none )

                Ok page ->
                    ( { model | viewRune = Success page }, Cmd.none )

        SetTableState s ->
            ( { model | tableState = s }, Cmd.none )


updateRoute : Url.Url -> Model -> ( Model, Cmd Msg )
updateRoute url model =
    let
        newModel =
            { model | url = url, route = fromUrl url }
    in
    case newModel.route of
        Just (Live (Just liveId)) ->
            ( newModel, Task.perform JoinLive <| Task.succeed liveId )

        Just (Guide Nothing) ->
            Models.RemoteData.map
                ( { newModel | runePages = Loading }, findRunes () )
                ( newModel, Cmd.none )
                ( newModel, Cmd.none )
                (always ( newModel, Cmd.none ))
                model.runePages

        Just (Guide (Just "new")) ->
            Models.RemoteData.map
                ( { newModel | runePages = Loading }, findRunes () )
                ( newModel, Cmd.none )
                ( newModel, Cmd.none )
                (always ( newModel, Cmd.none ))
                model.runePages

        Just (Guide (Just pageId)) ->
            case findRuneCache model pageId of
                Just page ->
                    ( { newModel | viewRune = Success page }, Cmd.none )

                Nothing ->
                    ( { newModel | viewRune = Loading }, Cmd.batch [ findRunes (), getRune pageId ] )

        _ ->
            ( newModel, Cmd.none )


findRuneCache : Model -> String -> Maybe RunePage
findRuneCache model pageId =
    case model.runePages of
        Success pages ->
            List.Extra.find (\page -> Maybe.withDefault False <| Maybe.map (\key -> key == pageId) page.key) pages

        _ ->
            Nothing



-- generateRandomLiveId : Cmd Msg
-- generateRandomLiveId =
--    Random.generate (\id -> StartLive (Just id)) <| Random.String.string 6 Random.Char.english
