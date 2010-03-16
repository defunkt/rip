module Rip
  class GitPackage < Package
    def self.handle?(source)
      source =~ /file:\/\// ||
        source =~ /git:\/\// ||
        source =~ /\.git/
    end

    def initialize(*args)
      super
      @version ||= "master"
    end

    def name
      super || source.split('/').last.chomp('.git')
    end

    # TODO: better name
    def ref
      ref = nil

      # Cache exists and we have a static reference
      if File.directory?(cache_path)
        ref = parse_git_rev(cache_path, version)
        ref = nil unless ref =~ /^#{version}/
      end

      # Update cache and deference
      unless ref
        update_cache
        ref = parse_git_rev(cache_path, version)
      end

      ref
    end

    def update_cache
      if File.directory?(cache_path)
        cd(cache_path) do
          system("git fetch -q &> /dev/null")
        end
      else
        system("git clone --bare --mirror #{source} #{cache_path} &> /dev/null")
      end
    end

    def parse_git_rev(path, rev)
      cd(path) do
        ref = `git rev-parse --verify --quiet #{rev}`.chomp
        return $?.success? ? ref : nil
      end
    end
  end
end
