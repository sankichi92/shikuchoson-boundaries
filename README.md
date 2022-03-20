# shikuchoson-boundaries

市区町村の行政区域界を GeoJSON で返す簡易 Web API。

[「国土数値情報（行政区域データ）」（国土交通省）](https://nlftp.mlit.go.jp/ksj/gml/datalist/KsjTmplt-N03-v3_0.html)から令和3年全国のデータ（N03-20210101_GML.zip）を加工して作成。

## API

### Base URL

https://shikuchoson-boundaries.sankichi.app/

### `GET /`

全市区町村の属性の一覧を JSON で返します。

#### 使用例

[jq](https://stedolan.github.io/jq/) を使用して市区町村名から行政区域コードを取得します。

```console
$ curl -s https://shikuchoson-boundaries.sankichi.app/ | jq '.[0:2]'
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
$ curl -s https://shikuchoson-boundaries.sankichi.app/ | jq '.[] | select(.["市区町村"] == "つくば市") | .["行政区域コード"]'
"08220"
```

### `GET /:code.geojson`

行政区域コード `:code` に対応する市区町村の行政区域界を GeoJSON で返します。

#### 使用例

```console
$ curl -s https://shikuchoson-boundaries.sankichi.app/08220.geojson | jq
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

[`gh-pages`](https://github.com/sankichi92/shikuchoson-boundaries/tree/gh-pages) ブランチでは、
https://github.com/sankichi92/shikuchoson-boundaries/blob/gh-pages/08220.geojson のように GitHub のプレビュー機能を使って視覚的に確認することもできます。

## License

[MIT License](https://opensource.org/licenses/MIT)
