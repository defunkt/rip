module Rip
  class GitPackage < Package
    handles "file://", "git://", "git+ssh://"

    def name
      @name ||= source.split('/').last.chomp('.git')
    end

    def fetch
      puts "fetching #{name}..."
      if File.exists? cache_path
        Dir.chdir cache_path do
          `git fetch origin`
        end
      else
        `git clone #{source} #{cache_name}`
      end
    end

    def unpack
      puts "unpacking #{name} #{version}..."
      Dir.chdir cache_path do
        `git reset --hard #{version}`
        `git submodule init`
        `git submodule update`
      end
    end

    def version
      return @version if @version
      Dir.chdir cache_path do
        @version = `git rev-parse origin/master`[0,7]
      end
    end
  end
end
