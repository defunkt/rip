require 'timeout'

module Rip
  class RemoteGemPackage < Package
    handles do |source|
      RemoteGemPackage.new(source).exists?
    end

    @@remotes = %w( gems.github.com gemcutter.org gems.rubyforge.org )
    @@exists_cache = {}

    def exists?
      return false unless source =~ /^[\w-]+$/
      return true if @@exists_cache[source] || File.exists?(cache_path)

      FileUtils.mkdir_p cache_path

      Dir.chdir cache_path do
        @@remotes.each do |remote|
          # hack: every github gem has a dash in its name
          next if remote =~ /github/ && !source.include?('-')

          ui.vputs "Searching %s for %s..." % [ remote, source ]

          source_flag = "--source=http://#{remote}/"
          if Sh::Gem.rgem("fetch #{source} #{source_flag}") =~ /Downloaded (.+)/
            ui.vputs "Found #{source} at #{remote}"
            @@exists_cache[source] = $1
            return true
          end
        end
      end

      FileUtils.rm_rf cache_path
      false
    end

    def meta_package?
      true
    end

    def fetch!
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
