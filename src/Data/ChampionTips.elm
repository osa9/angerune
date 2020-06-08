module Data.ChampionTips exposing (..)

import Dict exposing (Dict)
import Models.Champion exposing (Champion)



--| いつかDB化する


tips : Dict String (List String)
tips =
    Dict.fromList
        [ ( "Alistar", [ "絞っても乳は出ない" ] )
        , ( "Corki", [ "Wをハラスに使ってはいけない" ] )
        , ( "Jhin", [ "アイテム/ルーンでASは増加しない", "クリティカル発生時に10+増加AS(%)*40%のMS増加", "CritとAS増加でADが増加する" ] )
        , ( "Jinx", [ "Wをハラスに使ってはいけない" ] )
        , ( "MissFortune", [ "別の対象を攻撃する毎に追加物理ダメージ(AD×50〜100%)", "↑発動時にWのCD2秒減", "W(CD12s)：4秒間AS+40/55/70/85/100%" ] )
        , ( "Sivir", [ "RパッシブでW発動中はASが30/45/60%増加" ] )
        , ( "Teemo", [ "かわいい", "きのこのダメージは踏んだ時点でのTeemoのAPに依存" ] )
        , ( "Tristana", [ "Wをハラスに使ってはいけない" ] )
        , ( "Twitch", [ "通称ドブネズミ", "Qのステルス解除時に4秒間AS+30〜50%", "汚染(AA,W)されたチャンピオンが死ぬとQのCD解消" ] )
        , ( "Vayne", [ "同一個体に3回連続で通常攻撃すると最大HP×4〜14%のTrueDmg", "QはAAタイマーを解消する", "R中はQのCDが30〜50%減" ] )
        ]


getTips : Champion -> List String
getTips champ =
    Maybe.withDefault [] <| Dict.get champ.id tips
