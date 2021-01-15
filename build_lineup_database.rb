require_relative './utils/dependencies'

OUT_FILE = File.join(BASE_FILEPATH, 'data', 'nba_lineups.csv')

START_SEASON = 2007
END_SEASON = 2020

csv_row_names = NBA::Mappers::LINEUP_ROW_MAPPER.keys.map(&:upcase)

CSV.open(OUT_FILE, 'wb') do |csv|
  csv << csv_row_names

  (START_SEASON...END_SEASON).each do |year|
    next_year_2digit = (year + 1 - 2000).to_s.rjust(2, '0')
    season = [year, next_year_2digit].join('-')

    p "Retrieving lineup data for #{season}"

    url = "#{NBA::LINEUP_SOURCE_URL}&Season=#{season}"
    response = RestClient.get(url, NBA::HEADERS)
    processed_response = GZIPPER.process_web_response(response)
    lineup_rows = processed_response.dig('resultSets', 0, 'rowSet')
    lineup_rows.each do |row|
      mapped_row = NBA::Mappers::LINEUP_ROW_MAPPER.values.map { |lambda| lambda.call(row) }
      csv << mapped_row
    end
  end
end

