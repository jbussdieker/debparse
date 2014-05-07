module Debparse
  class Release
    FOLDED_TYPES = ["Description"]
    MULTILINE_TYPES = ["MD5Sum", "SHA1", "SHA256"]

    attr_accessor :origin, :label, :suite, :version, :codename, :date, :architectures, :components, :description, :md5sum, :sha1, :sha256

    def initialize(params = {})
      params.each do |k, v|
        send("#{k.downcase}=", v)
      end
    end

    def architectures=(data)
      @architectures = data.split(" ")
    end

    def components=(data)
      @components = data.split(" ")
    end

    def self.parse(data)
      params = {}.tap do |params|
        lines = data.split("\n")
        
        while lines.length > 0
          line = lines.shift

          if line[0] != " "
            key, value = line.split(":", 2)
            params[key] = (value || "").lstrip

            #puts key
            if MULTILINE_TYPES.include? key
              params[key] = []
              #puts "  multiline"
              while lines.length > 0 && lines[0][0] == " " do
                params[key] << lines.shift
              end
            elsif FOLDED_TYPES.include? key
              #puts "  folded"
              while lines.length > 0 && lines[0][0] == " " do
                params[key] << lines.shift
              end
            else
              #puts "  simple"
            end
          end
        end
      end
      new(params)
    end
  end
end
