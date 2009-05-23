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

    def meta_package?
      true
    end

    def cached?
      false
    end

    def fetch!
    end

    def unpack!
      FileUtils.rm_rf cache_path
      FileUtils.mkdir_p cache_path
      FileUtils.cp source, cache_path
    end

    def dependencies!
      if File.exists? deps = File.join(cache_path, name)
        File.readlines(deps).map do |line|
          source, version, *extra = line.split(' ')
          Package.for(source, version)
        end
      else
        []
      end
    end
  end
end
