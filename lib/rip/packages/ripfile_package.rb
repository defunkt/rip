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
      source.split('/').last.chomp('.rip')
    end

    def meta_package?
      true
    end

    def fetch!
    end

    def unpack!
      FileUtils.rm_rf cache_path
      FileUtils.mkdir_p cache_path
      FileUtils.cp source, cache_path
    end
  end
end
