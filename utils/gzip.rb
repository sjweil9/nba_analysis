module Basketball
  module Utils
    class Gzip
      def self.process_web_response(response)
        json_raw = Zlib::GzipReader.new(StringIO.new(response.body)).read
        JSON.parse(json_raw)
      end
    end
  end
end