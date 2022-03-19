# shikuchoson-boundaries

行政区域コードから市区町村の境界を GeoJSON で取得するための簡易 Web API。

[「国土数値情報（行政区域データ）」（国土交通省）](https://nlftp.mlit.go.jp/ksj/gml/datalist/KsjTmplt-N03-v3_0.html)を加工して作成。

## API

### Base URL

https://sankichi.net/shikuchoson-boundaries/

### `GET /`

全市区町村を JSON で返します。

```console
$ curl -s https://sankichi.net/shikuchoson-boundaries/ | jq '.[0:2]'
[
  {
    "都道府県": "北海道",
    "支庁・振興局": "石狩振興局",
    "郡・政令都市": "札幌市",
    "市区町村": "中央区",
    "行政区域コード": "01101"
  },
  {
    "都道府県": "北海道",
    "支庁・振興局": "石狩振興局",
    "郡・政令都市": "札幌市",
    "市区町村": "北区",
    "行政区域コード": "01102"
  }
]
$ curl -s https://sankichi.net/shikuchoson-boundaries/ | jq '.[] | select(.["市区町村"] == "つくば市") | .["行政区域コード"]'
"08220"
```

### `GET /:code.geojson`

行政区域コード `:code` に対応する市区町村の行政区域を GeoJSON で返します。

```console
$ curl -s https://sankichi.net/shikuchoson-boundaries/08220.geojson | jq
{
  "type": "Feature",
  "properties": {
    "都道府県": "茨城県",
    "市区町村": "つくば市",
    "行政区域コード": "08220"
  },
  "geometry": {
    "type": "Polygon",
    "coordinates": [
      [
        [
          140.05993105137702,
          36.23617286468601
        ],
        [
          140.05996105096176,
          36.23596341348082
        ],
        // ...
      ]
    ]
  }
}
```

## License

[MIT License](https://opensource.org/licenses/MIT)
