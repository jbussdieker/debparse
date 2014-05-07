module Debparse
  class Packages
    FOLDED_TYPES = ["Description"]
    MULTILINE_TYPES = ["MD5Sum", "SHA1", "SHA256"]

    attr_accessor :package, :priority, :section, :installed_size, :size, :maintainer, :architecture, :source, :version, :depends, :filename, :md5sum, :sha1, :sha256, :description, :description_md5, :bugs, :origin, :supported, :original_maintainer, :suggests, :homepage, :task, :multi_arch, :recommends, :conflicts, :replaces, :breaks, :provides, :pre_depends, :enhances, :original_vcs_browser, :original_vcs_git, :build_essential, :python_version, :orginal_maintainer, :essential, :tag, :xul_appid, :gstreamer_elements, :gstreamer_version, :gstreamer_decoders, :gstreamer_encoders, :gstreamer_uri_sinks, :gstreamer_uri_sources, :npp_applications, :npp_description, :npp_mimetype, :npp_name, :debian_vcs_browser, :debian_vcs_svn, :python3_version, :ruby_versions, :npp_filename, :orig_maintainer

    def initialize(params = {})
      params.each do |k, v|
        send("#{k.downcase.gsub('-', '_')}=", v)
      end
    end

    def self.parse_paragraph(data)
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

    def self.parse(data)
      gz = Zlib::GzipReader.new(StringIO.new(data))    
      data = gz.read
      [].tap do |list|
        data.split("\n\n").each do |paragraph|
          list << parse_paragraph(paragraph)
        end
      end
    end
  end
end
