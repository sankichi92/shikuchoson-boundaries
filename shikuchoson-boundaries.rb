# frozen_string_literal: true

require 'net/http'
require 'uri'

require 'active_support/core_ext/big_decimal/conversions'
require 'active_support/core_ext/object/deep_dup'
require 'oj'
require 'zip'

DATA_URL = 'https://nlftp.mlit.go.jp/ksj/gml/data/N03/N03-2021/N03-20210101_GML.zip'

TMP_DIR = File.expand_path('tmp', __dir__)
OUTPUT_DIR = File.expand_path('output', __dir__)

Dir.mkdir(TMP_DIR) unless File.exist?(TMP_DIR)
Dir.mkdir(OUTPUT_DIR) unless File.exist?(OUTPUT_DIR)

data_path = File.join(TMP_DIR, File.basename(DATA_URL))

unless File.exist?(data_path)
  puts "Downloading #{DATA_URL} ..."
  response = Net::HTTP.get_response(URI(DATA_URL))
  File.write(data_path, response.body)
end

puts 'Extracting a GeoJSON file from the donloaded zip file ...'
geojson_str = Zip::File.open(data_path) do |zip_file|
  geojson_entry = zip_file.glob('*.geojson').first
  geojson_entry.get_input_stream.read
end

puts 'Parsing GeoJSON ...'
geojson = Oj.load(geojson_str, bigdecimal_load: :bigdecimal)

puts 'Outputing GeoJSON files ...'
properties = []
geojson['features']
  .reject { |f| f['properties']['N03_007'].nil? } # 所属未定地を除く
  .group_by { |f| f['properties']['N03_007'] }
  .each do |code, features|
    abort 'Unexpected properties' if features.map { |f| f['properties'] }.uniq.size > 1

    feature = features.first.deep_dup
    feature['properties'].transform_keys!(
      'N03_001' => '都道府県',
      'N03_002' => '支庁・振興局',
      'N03_003' => '郡・政令都市',
      'N03_004' => '市区町村',
      'N03_007' => '行政区域コード'
    ).compact!
    properties << feature['properties']

    if features.size > 1 # 1つの行政区域コードに複数の feature がある場合は、Polygon をマージして MultiPolygon にする
      abort 'Unexpected geometry type' if features.any? { |f| f['geometry']['type'] != 'Polygon' }

      feature['geometry']['type'] = 'MultiPolygon'
      feature['geometry']['coordinates'] = features.map { |f| f['geometry']['coordinates'] }
    end

    feature['bbox'] = features.inject([180, 90, -180, -90]) do |result, f|
      f['geometry']['coordinates'].first.inject(result) do |r, point|
        [[r[0], point[0]].min, [r[1], point[1]].min, [r[2], point[0]].max, [r[3], point[1]].max]
      end
    end

    File.write(
      File.join(OUTPUT_DIR, "#{code}.geojson"),
      Oj.dump(feature.slice('type', 'bbox', 'properties', 'geometry'), bigdecimal_as_decimal: true)
    )
  end

File.write(
  File.join(OUTPUT_DIR, 'index.json'),
  Oj.dump(properties.sort_by { |p| p['行政区域コード'].to_i })
)
