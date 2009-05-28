module Rip
  class GitPackage < Package
    handles "file://", "git://", /\.git$/

    memoize :name
    def name
      source.split('/').last.chomp('.git')
    end

    def version
      return @version if @version

      fetch
      Dir.chdir cache_path do
        @version = `git rev-parse origin/master`[0,7]
      end
    end
    
    def exists?
      case source
      when /^file:/
        file_exists?
      when /^git:/
        remote_exists?
      when /\.git$/
        file_exists? || remote_exists?
      else
        false
      end
    end

    def fetch!
      if File.exists? cache_path
        Dir.chdir cache_path do
          `git fetch origin`
        end
      else
        `git clone #{source} #{cache_name}`
      end
    end

    def unpack!
      Dir.chdir cache_path do
        `git reset --hard #{version}`
        `git submodule init`
        `git submodule update`
      end
    end

    private
    def file_exists?
      File.exists? File.join(source.sub('file://', ''), '.git')
    end

    def remote_exists?
      out = `git ls-remote #{source} #{@version} 2> /dev/null`
      out.include? @version || 'HEAD'
    end
  end
end
