module Basketball
  module Utils
    class NBA
      module Mappers
        PLAYER_ROW_MAPPER = {
          id: lambda { |row| row[0] },
          last_name: lambda { |row| row[1].upcase },
          first_name: lambda { |row| row[2].upcase },
          name: lambda { |row| normalize_name([row[2], row[1]].join(' ')) },
          team: lambda { |row| row[9] },
          position: lambda { |row| row[11]&.delete('-') },
          height: lambda { |row| row[12] },
          weight: lambda { |row| row[13] },
          draft_year: lambda { |row| row[16] },
        }.with_indifferent_access

        LINEUP_ROW_MAPPER = {
          lineup_type: lambda { |row| calculate_lineup_type(row) },
          p1: lambda { |row| lineup_players(row)[0] },
          p2: lambda { |row| lineup_players(row)[1] },
          p3: lambda { |row| lineup_players(row)[2] },
          p4: lambda { |row| lineup_players(row)[3] },
          p5: lambda { |row| lineup_players(row)[4] },
          min: lambda { |row| row[9] },
          fgm: lambda { |row| row[10] },
          fga: lambda { |row| row[11] },
          fg3m: lambda { |row| row[13] },
          fg3a: lambda { |row| row[14] },
          ftm: lambda { |row| row[16] },
          fta: lambda { |row| row[17] },
          oreb: lambda { |row| row[19] },
          dreb: lambda { |row| row[20] },
          ast: lambda { |row| row[22] },
          tov: lambda { |row| row[23] },
          stl: lambda { |row| row[24] },
          blk: lambda { |row| row[25] },
          blka: lambda { |row| row[26] },
          pf: lambda { |row| row[27] },
          pfd: lambda { |row| row[28] },
          pts: lambda { |row| row[29] },
          plus_minus: lambda { |row| row[30] },
          team: lambda { |row| row[4] },
        }.with_indifferent_access

        START_OF_RS_ADV = 65
        START_OF_PL = 144
        START_OF_PL_ADV = 209

        PLAYER_SEASON_ROW_MAPPER = {
          season: lambda { |row| row[1] },
          rs_total_mins: lambda { |row| row[9] },
          rs_mins_36: lambda { |row| row[START_OF_RS_ADV + 9] },
          pl_total_mins: lambda { |row| row[START_OF_PL + 10] },
          pl_mins_36: lambda { |row| row[START_OF_PL_ADV + 9] },
          rs_netrtg: lambda { |row| row[START_OF_RS_ADV + 17] },
          pl_netrtg: lambda { |row| row[START_OF_PL_ADV + 17] },
          rs_ast_36: lambda { |row| row[22] },
          pl_ast_36: lambda { |row| row[START_OF_PL + 22] },
          rs_reb_36: lambda { |row| row[21] },
          pl_reb_36: lambda { |row| row[START_OF_PL + 21] },
          rs_efg: lambda { |row| row[START_OF_RS_ADV + 27] },
          pl_efg: lambda { |row| row[START_OF_PL_ADV + 27] },
          rs_tspct: lambda { |row| row[START_OF_RS_ADV + 28] },
          pl_tspct: lambda { |row| row[START_OF_PL_ADV + 28] },
          rs_usg: lambda { |row| row[START_OF_RS_ADV + 29] },
          pl_usg: lambda { |row| row[START_OF_PL_ADV + 29] },
          rs_blk_36: lambda { |row| row[25] },
          pl_blk_36: lambda { |row| row[START_OF_PL + 25] },
          rs_stl_36: lambda { |row| row[24] },
          pl_stl_36: lambda { |row| row[START_OF_PL + 24] },
          rs_tov_36: lambda { |row| row[23] },
          pl_tov_36: lambda { |row| row[START_OF_PL + 23] },
        }.with_indifferent_access
      end
    end
  end
end