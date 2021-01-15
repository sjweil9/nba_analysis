require_relative './nba/mappers'

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
        lineup_players(row).map { |player| find_player(row[4], player)&.dig(:position) }.sort.join('-')
      end

      def self.find_player(team, normalized_name)
        players.detect { |player| player[:team] == team && player[:normalized_name] == normalized_name }
      end

      def self.lineup_players(row)
        row[2].split(' - ').map { |player| normalize_name(player) }
      end

      def self.players
        return @players if @players

        @players = []
        CSV.foreach(File.join(BASE_FILEPATH, 'data', 'nba_players.csv'), headers: true) do |row|
          @players << {
            nba_id: row[0],
            team: row[4],
            position: row[5],
            height: row[6],
            weight: row[7],
            draft_year: row[8],
            normalized_name: row[3],
          }
        end

        @players
      end
    end
  end
end