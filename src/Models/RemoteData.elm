module Models.RemoteData exposing (..)


type RemoteData a
    = NotAsked
    | Loading
    | Failure
    | Success a


map : b -> b -> b -> (a -> b) -> RemoteData a -> b
map notasked loading failure success data =
    case data of
        NotAsked ->
            notasked

        Loading ->
            loading

        Failure ->
            failure

        Success a ->
            success a
