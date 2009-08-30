module Rip
  class RipfilePackage < Package
    handles '.rip'

    def initialize(source, *args)
      super
      @source = File.expand_path(source)
    end

    def exists?
      File.exists? source
    end

    def name
      source.split('/').last
    end

    def version
      nil
    end
    
    def actual_package
      nil
    end

    def meta_package?
      true
    end

    def cached?
      false
    end

    def dependency_installed(dependency, success = true)
      if !success
        ui.puts "rip: already installed #{dependency}"
      end
    end

    def fetch!
      FileUtils.rm_rf cache_path
      FileUtils.mkdir_p cache_path
      FileUtils.cp source, File.join(cache_path, name)
    end

    def unpack!
      fetch
    end

    def dependencies!
      if File.exists? deps = File.join(cache_path, name)
        lines = File.readlines(deps)

        # Ignore blank lines and comments
        lines = lines.select { |l| l =~ /\S/ && l !~ /^#/ }

        lines.map do |line|
          package_source, version, *extra = line.split(' ')
          if package = Package.for(package_source, version)
            package
          else
            # Allows .rip file and dir packages to be listed as
            # relative paths.
            path = File.join(File.dirname(@source), package_source)
            Package.for(path, version)
          end
        end
      else
        []
      end
    end
  end
end
