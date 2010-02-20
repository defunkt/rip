module Rip
  class Package
    class PathNotFound < RuntimeError; end

    attr_reader :path
    def initialize(path)
      if path.to_s.empty? || !File.exists?(path = File.expand_path(path))
        raise PathNotFound
      end

      @path = path
    end

    def name
      File.basename(@path)
    end

    def version
      git("rev-parse HEAD")[0,8]
    end

    def git(command)
      `git --git-dir=#{@path}/.git #{command}`.chomp
    end
  end
end
