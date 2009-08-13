require 'rip/gems'

module Rip
  class GemPackage < Package
    handles '.gem'

    def initialize(source, *args)
      super
      @source = File.expand_path(source.strip.chomp)
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
      ui.abort "can't find your gem command" unless Sh::Gems.check?

      File.exists?(source)
    end

    def fetch!
      FileUtils.cp File.expand_path(source), cache_file
    end

    def unpack!
      Sh::Gems.rgem("unpack '#{cache_file}' --target='#{packages_path}' > /dev/null")
    end

    def dependencies!
      Sh::Gems.dependencies(name)
    end

    memoize :metadata
    def metadata
      parts = source.split('/').last.chomp('.gem').split('-')
      { :name => parts[0...-1].join('-'), :version => parts[-1] }
    end
  end
end
