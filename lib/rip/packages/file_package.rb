module Rip
  class FilePackage < Package
    handles do |source|
      File.directory? source
    end

    def initialize(source, *args)
      super
      @source = File.expand_path(source)
    end

    def exists?
      File.directory? source
    end

    memoize :name
    def name
      source.split('/').last
    end

    def version
      "unversioned"
    end

    def fetch!
      FileUtils.rm_rf cache_path
      FileUtils.cp_r "#{source}/.", cache_path
    end
  end
end
