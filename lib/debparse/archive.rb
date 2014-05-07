module Debparse
  class Archive
    attr_accessor :connection, :dist

    def initialize(connection, dist)
      @connection = connection
      @dist = dist
    end

    def release
      resp = connection.request("dists/#{dist}/Release")
      Debparse::Release.parse(resp)
    end

    def packages(component, section)
      resp = connection.request("dists/#{dist}/#{component}/#{section}/Packages.gz")
      Debparse::Packages.parse(resp)
    end
  end
end
