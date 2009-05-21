module Rip
  class FilePackage < Package
    handles do |source|
      File.exists? source
    end

    def exists?
      File.exists? source
    end

    memoize :name
    def name
      source.split('/').last
    end

    memoize :version
    def version
      "unversioned"
    end

    def fetch
      return if File.exists? cache_path
      super
      FileUtils.cp_r "#{source}/.", cache_path
    end

    def unpack
      super
    end
  end
end
