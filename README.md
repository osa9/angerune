# AngeRune (えんじぇる〜ん)
## Setup
### Riotのオープンデータ(Data Dragon)をダウンロード
https://developer.riotgames.com/docs/lol

```shell script
$ curl -O https://ddragon.leagueoflegends.com/cdn/dragontail-10.10.3208608.zip
$ unzip dragontail-*.zip
$ mv dragontail-* ./public/dragontail
```

### Firebaseの設定
```shell script
$ firebase init
```

src/firebase.config.js.exampleをfirebase.config.jsにリネームしてfirebaseの設定情報を入れる
