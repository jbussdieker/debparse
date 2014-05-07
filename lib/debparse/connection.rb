module Debparse
  class Connection
    attr_accessor :url

    def initialize(url)
      @url = url
      @cache_file = File.join("tmp", sanitized_file_name_from(@url))
      FileUtils.mkdir_p(@cache_file)
    end

    def request(path)
      cache_file = File.join(@cache_file, path.gsub("/", "_"))

      if File.exists? cache_file
        return File.read(cache_file)
      else
        req = make_request(path)
        resp = client.request(req)
        resp
        File.open(cache_file, "w") do |f|
          f.write(resp.body)
        end
        return resp.body
      end
    end

    private

    def sanitized_file_name_from(file_name)
      file_name.gsub(/[^\w\-]+/, '_')
    end

    def uri
      URI.parse(url)
    end

    def client
      Net::HTTP.new(uri.host, uri.port)
    end

    def make_request(path)
      Net::HTTP::Get.new(URI.join(url, path).path)
    end
  end
end
