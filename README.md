# shikuchoson-boundaries

行政区域コードから市区町村の境界を GeoJSON で取得するための簡易 Web API。

[「国土数値情報（行政区域データ）」（国土交通省）](https://nlftp.mlit.go.jp/ksj/gml/datalist/KsjTmplt-N03-v3_0.html)を加工して作成。

## API

### Base URL

https://sankichi.net/shikuchoson-boundaries/

### `GET /`

全市区町村を JSON で返します。

```console
$ curl -s https://sankichi.net/shikuchoson-boundaries/ | jq '.[0]'
{
  "都道府県": "北海道",
  "支庁・振興局": "石狩振興局",
  "郡・政令都市": "札幌市",
  "市区町村": "中央区",
  "行政区域コード": "01101"
}
$ curl -s https://sankichi.net/shikuchoson-boundaries/ | jq '.[] | select(.["市区町村"] == "つくば市") | .["行政区域コード"]'
"08220"
```

### `GET /:code.geojson`

行政区域コード `:code` に対応する市区町村の行政区域を GeoJSON で返します。

```console
$ curl https://sankichi.net/shikuchoson-boundaries/08220.geojson
```

## License

[MIT License](https://opensource.org/licenses/MIT)
