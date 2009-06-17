require 'timeout'

module Rip
  class RemoteGemPackage < Package
    handles do |source|
      RemoteGemPackage.new(source).exists?
    end

    @@remotes = %w( gems.github.com gems.rubyforge.org )
    @@exists_cache = {}

    def exists?
      return false unless source =~ /^[\w-]+$/
      return true if @@exists_cache[source] || File.exists?(cache_path)

      FileUtils.mkdir_p cache_path

      Dir.chdir cache_path do
        @@remotes.each do |remote|
          ui.puts "Searching %s for %s..." % [ remote, source ]

          source_flag = "--source=http://#{remote}/"
          if rgem("fetch #{source} #{source_flag}") =~ /Downloaded (.+)/
            @@exists_cache[source] = $1
            return true
          end
        end
      end

      false
    end

    def rgem(command)
      Timeout.timeout(5) do
        `#{gembin} #{command}`
      end
    rescue Timeout::Error
      ''
    end

    def meta_package?
      true
    end

    def fetch!
    end

    def unpack!
      installer = Installer.new
      installer.install actual_package
      installer.manager.sources[actual_package.name] = source
      installer.manager.save
    end

    def version
      actual_package ? actual_package.version : super
    end

    memoize :actual_package
    def actual_package
      Package.for(Dir[cache_path + '/*'].first)
    end

    def gembin
      ENV['GEMBIN'] || 'gem'
    end
  end
end
