require 'timeout'

module Rip
  class RemoteGemPackage < Package
    handles do |source|
      RemoteGemPackage.new(source).exists?
    end

    def meta_package?
      true
    end

    def exists?
      File.exists?(cache_path) || Sh::Gem.exists?(source)
    end

    def fetch!
      return if File.exists?(cache_path)
      FileUtils.mkdir_p cache_path

      Dir.chdir cache_path do
        ui.puts "Fetching #{self} via Rubygems..."
        unless Sh::Gem.fetch(source, version)
          FileUtils.rm_rf cache_path
          ui.abort "Couldn't find gem #{source} in any of your gem sources"
        end
      end
    end

    def unpack!
      installer = Installer.new
      installer.install actual_package, self
      installer.manager.sources[actual_package.name] = source
      installer.manager.save
    end

    def dependencies!
      actual_package.dependencies
    end

    def files
      actual_package.files
    end

    def version
      local_gem ? actual_package.version : @version
    end

    memoize :actual_package
    def actual_package
      Package.for(local_gem)
    end

    def local_gem
      Dir[cache_path + '/*'].first
    end
  end
end
