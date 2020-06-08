# AngeRune (えんじぇる〜ん)

## Setup

### Riot のオープンデータ(Data Dragon)をダウンロード

https://developer.riotgames.com/docs/lol

```shell script
$ curl -O https://ddragon.leagueoflegends.com/cdn/dragontail-10.10.3208608.zip
$ unzip dragontail-*.zip -d public/dragontail
```

### Firebase の設定

```shell script
$ firebase init
```

src/firebase.config.js.example を firebase.config.js にリネームして firebase の設定情報を入れる
