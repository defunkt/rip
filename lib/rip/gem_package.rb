module Rip
  class GemPackage < Package
    handles '.gem'

    def initialize(source, version = nil)
      @source = File.expand_path(source.strip.chomp)
      @version = version
    end

    def name
      metadata[:name]
    end

    def version
      metadata[:version]
    end

    def cache_file
      "#{cache_path}.gem"
    end

    def exists?
      File.exists? source
    end

    def fetch
      super
      FileUtils.cp File.expand_path(source), cache_file
    end

    def unpack
      super
      system "gem unpack #{cache_file} --target=#{packages_path}"
    end

    def metadata
      parts = source.split('/').last.chomp('.gem').split('-')
      { :name => parts[0...-1].join('-'), :version => parts[-1] }
    end
  end
end
