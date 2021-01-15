require_relative './utils/dependencies'

OUT_FILE = File.join(BASE_FILEPATH, 'data', 'nba_players.csv')

response = RestClient.get(NBA::PLAYER_SOURCE_URL, NBA::HEADERS)
processed_response = GZIPPER.process_web_response(response)
player_rows = processed_response.dig('resultSets', 0, 'rowSet')

csv_row_names = NBA::Mappers::PLAYER_ROW_MAPPER.keys.map(&:upcase)

CSV.open(OUT_FILE, 'wb') do |csv|
  csv << csv_row_names

  player_rows.each do |row|
    mapped_row = NBA::Mappers::PLAYER_ROW_MAPPER.values.map { |lambda| lambda.call(row) }
    csv << mapped_row
  end
end
