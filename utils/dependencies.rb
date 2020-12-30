require 'rest-client'
require 'json'
require 'active_support/all'
require 'csv'

require_relative './nba'
require_relative './gzip'

GZIPPER = Basketball::Utils::Gzip
NBA = Basketball::Utils::NBA

BASE_FILEPATH = '/home/sjweil/Documents/Coding/basketball/nba_lineups'