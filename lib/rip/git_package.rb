module Rip
  class GitPackage < Package
    handles "file://", "git://"

    memoize :name
    def name
      source.split('/').last.chomp('.git')
    end

    memoize :version
    def version
      fetch
      Dir.chdir cache_path do
        `git rev-parse origin/master`[0,7]
      end
    end

    def exists?
      case source
      when /^file:/
        File.exists? File.join(source.sub('file://', ''), '.git')
      when /^git:/
        out = `git ls-remote #{source} #{@version} 2> /dev/null`
        out.include? @version || 'HEAD'
      else
        false
      end
    end

    def fetch
      return if @fetched

      puts "fetching #{name}..."
      if File.exists? cache_path
        Dir.chdir cache_path do
          `git fetch origin`
        end
      else
        `git clone #{source} #{cache_name}`
      end

      @fetched = true
    end

    def unpack
      puts "unpacking #{name} #{version}..."
      Dir.chdir cache_path do
        `git reset --hard #{version}`
        `git submodule init`
        `git submodule update`
      end
    end
  end
end
