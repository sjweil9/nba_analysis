require_relative './utils/dependencies'

OUT_FILE = File.join(BASE_FILEPATH, 'data', 'nba_player_seasons.csv')

csv_row_names = ['Player ID', 'Player Name'] + NBA::Mappers::PLAYER_SEASON_ROW_MAPPER.keys.map(&:upcase)

EARLIEST_YEAR = 2003

#expected_base_columns = ["GROUP_SET", "GROUP_VALUE", "TEAM_ID", "TEAM_ABBREVIATION", "MAX_GAME_DATE", "GP", "W", "L", "W_PCT", "MIN", "FGM", "FGA", "FG_PCT", "FG3M", "FG3A", "FG3_PCT", "FTM", "FTA", "FT_PCT", "OREB", "DREB", "REB", "AST", "TOV", "STL", "BLK", "BLKA", "PF", "PFD", "PTS", "PLUS_MINUS", "NBA_FANTASY_PTS", "DD2", "TD3", "GP_RANK", "W_RANK", "L_RANK", "W_PCT_RANK", "MIN_RANK", "FGM_RANK", "FGA_RANK", "FG_PCT_RANK", "FG3M_RANK", "FG3A_RANK", "FG3_PCT_RANK", "FTM_RANK", "FTA_RANK", "FT_PCT_RANK", "OREB_RANK", "DREB_RANK", "REB_RANK", "AST_RANK", "TOV_RANK", "STL_RANK", "BLK_RANK", "BLKA_RANK", "PF_RANK", "PFD_RANK", "PTS_RANK", "PLUS_MINUS_RANK", "NBA_FANTASY_PTS_RANK", "DD2_RANK", "TD3_RANK", "CFID", "CFPARAMS"]
#expected_advanced_columns =  ["GROUP_SET", "GROUP_VALUE", "TEAM_ID", "TEAM_ABBREVIATION", "MAX_GAME_DATE", "GP", "W", "L", "W_PCT", "MIN", "E_OFF_RATING", "OFF_RATING", "sp_work_OFF_RATING", "E_DEF_RATING", "DEF_RATING", "sp_work_DEF_RATING", "E_NET_RATING", "NET_RATING", "sp_work_NET_RATING", "AST_PCT", "AST_TO", "AST_RATIO", "OREB_PCT", "DREB_PCT", "REB_PCT", "TM_TOV_PCT", "E_TOV_PCT", "EFG_PCT", "TS_PCT", "USG_PCT", "E_USG_PCT", "E_PACE", "PACE", "PACE_PER40", "sp_work_PACE", "PIE", "POSS", "FGM", "FGA", "FGM_PG", "FGA_PG", "FG_PCT", "GP_RANK", "W_RANK", "L_RANK", "W_PCT_RANK", "MIN_RANK", "E_OFF_RATING_RANK", "OFF_RATING_RANK", "sp_work_OFF_RATING_RANK", "E_DEF_RATING_RANK", "DEF_RATING_RANK", "sp_work_DEF_RATING_RANK", "E_NET_RATING_RANK", "NET_RATING_RANK", "sp_work_NET_RATING_RANK", "AST_PCT_RANK", "AST_TO_RANK", "AST_RATIO_RANK", "OREB_PCT_RANK", "DREB_PCT_RANK", "REB_PCT_RANK", "TM_TOV_PCT_RANK", "E_TOV_PCT_RANK", "EFG_PCT_RANK", "TS_PCT_RANK", "USG_PCT_RANK", "E_USG_PCT_RANK", "E_PACE_RANK", "PACE_RANK", "sp_work_PACE_RANK", "PIE_RANK", "FGM_RANK", "FGA_RANK", "FGM_PG_RANK", "FGA_PG_RANK", "FG_PCT_RANK", "CFID", "CFPARAMS"]

CSV.open(OUT_FILE, 'wb') do |csv|
  csv << csv_row_names

  NBA.players.each do |hash|
    next unless hash[:draft_year].to_i >= EARLIEST_YEAR && hash[:normalized_name] == 'A. BURKS'

    nba_id = hash[:nba_id]
    combined_rows = %w[Regular+Season Playoffs].reduce({}) do |combined, season_type|
      %w[Base Advanced].each do |measure_type|
        url = "https://stats.nba.com/stats/playerdashboardbyyearoveryear?DateFrom=&DateTo=&GameSegment=&LastNGames=0&LeagueID=00&Location=&MeasureType=#{measure_type}"\
              "&Month=0&OpponentTeamID=0&Outcome=&PORound=0&PaceAdjust=N&PerMode=Per36&Period=0&PlayerID=#{nba_id}&PlusMinus=N&Rank=N&Season=2020-21&SeasonSegment="\
              "&SeasonType=#{season_type}&ShotClockRange=&Split=yoy&VsConference=&VsDivision="
        p "Retrieving data for #{nba_id}/#{hash[:normalized_name]}: #{season_type}/#{measure_type}"
        response = RestClient.get(url, NBA::HEADERS)
        processed_response = GZIPPER.process_web_response(response)
        #headers = processed_response.dig('resultSets', 1, 'headers')
        #target_headers = measure_type == 'Base' ? expected_base_columns : expected_advanced_columns
        year_rows = processed_response.dig('resultSets', 1, 'rowSet')
        year_rows.each do |row|
          combined[row[1]] ||= []
          combined[row[1]] += row
        end
      end
      combined
    end
    combined_rows.each do |_year, row|
      mapped_row = [nba_id, hash[:normalized_name]] + NBA::Mappers::PLAYER_SEASON_ROW_MAPPER.values.map { |lambda| lambda.call(row) }
      csv << mapped_row
    end
  end
end


