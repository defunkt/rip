require 'timeout'

module Rip
  class RemoteGemPackage < Package
    handles do |source|
      Sh::Gem.exists?(source)
    end

    def meta_package?
      true
    end

    def fetch!
      return if File.exists?(cache_path)
      FileUtils.mkdir_p cache_path

      Dir.chdir cache_path do
        ui.puts "Installing #{source} via Rubygems..."
        unless Sh::Gem.fetch(source)
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

    def version
      actual_package ? actual_package.version : super
    end

    memoize :actual_package
    def actual_package
      Package.for(Dir[cache_path + '/*'].first)
    end
  end
end
