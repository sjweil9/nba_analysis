module Basketball
  module Utils
    class NBA
      HEADERS = {
        :Host=>"stats.nba.com",
        :"User-Agent"=>"Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:61.0) Gecko/20100101 Firefox/61.0",
        :Accept=>"application/json, text/plain, */*",
        :"Accept-Language"=>"en-US,en;q=0.5",
        :Referer=>"https://stats.nba.com/",
        :"Accept-Encoding"=>"gzip, deflate, br",
        :Connection=>"keep-alive",
        :"x-nba-stats-origin"=>"stats",
        :"x-nba-stats-token"=>"true",
        :Origin=>"https://stats.nba.com",
        :"Content-Type"=>"application/json"
      }

      PLAYER_SOURCE_URL = "https://stats.nba.com/stats/playerindex?College=&Country=&DraftPick=&DraftRound=&DraftYear=&Height="\
                          "&Historical=1&LeagueID=00&Season=2020-21&SeasonType=Regular Season&TeamID=0&Weight="

      LINEUP_SOURCE_URL = "https://stats.nba.com/stats/leaguedashlineups?Conference=&DateFrom=&DateTo=&Division=&GameID="\
                          "&GameSegment=&GroupQuantity=5&LastNGames=0&LeagueID=00&Location=&MeasureType=Base&Month=0"\
                          "&OpponentTeamID=0&Outcome=&PORound=0&PaceAdjust=N&PerMode=Per100Possessions&Period=0&PlusMinus=N"\
                          "&Rank=N&SeasonSegment=&SeasonType=Regular Season&ShotClockRange=&TeamID=0&VsConference=&VsDivision="

      IRREGULAR_NAMES = {
        'YAO': 'M. YAO',
        'R. MURRAY': 'F. MURRAY', # NBA Player Data has him by "Flip Murray"
        'J. NAVARRO': 'J. CARLOS NAVARRO', # NBA Player Data has full name
        'NENE': 'N. HILARIO',
        'J. MCADOO':'J. MICHAEL MCADOO',
        'W. TAVARES':'E. TAVARES', # Hawks Legend
        'D. HOUSE':'D. HOUSE JR.', # Daammmnnn Danuel
        'K. KNOX':'K. KNOX II',
      }.with_indifferent_access

      def self.normalize_name(name)
        return name unless name.present?

        name = name.upcase
        return IRREGULAR_NAMES[name] if IRREGULAR_NAMES.key?(name)

        names = name.split(' ')
        first_initial = names[0].first(1)
        "#{first_initial}. #{names[1..-1].join(' ')}"
      end

      def self.calculate_lineup_type(row)
        lineup = row[2]
        players = lineup.split(' - ').map { |player| normalize_name(player) }
        positions = players.map { |player| player_map.dig(player, :position) }
        positions.sort.join('-')
      end

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
        plus_minus: lambda { |row| row[30] }
      }.with_indifferent_access

      def self.player_map
        return @player_map if @player_map

        @player_map = {}
        CSV.foreach(File.join(BASE_FILEPATH, 'data', 'nba_players.csv'), headers: true) do |row|
          @player_map[row[3]] = {
            team: row[4],
            position: row[5],
            height: row[6],
            weight: row[7],
            draft_year: row[8]
          }
        end

        @player_map
      end
    end
  end
end