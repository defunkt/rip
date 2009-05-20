module Rip
  class FilePackage < Package
    handles do |source|
      File.exists? File.expand_path(source)
    end

    def name
      @name ||= source.split('/').last
    end

    def fetch
      return if File.exists? cache_path
      super
      FileUtils.cp_r "#{source}/.", cache_path
    end

    def unpack(version)
      super
    end

    def infer_version
      "unversioned"
    end
  end
end
