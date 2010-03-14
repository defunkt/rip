module Rip
  class GitPackage < Package
    def self.handle?(source)
      source =~ /file:\/\// ||
        source =~ /git:\/\// ||
        source =~ /\.git/
    end

    def name
      super || source.split('/').last.chomp('.git')
    end

    def version
      super || "master"
    end

    def ref
      sh("rip-deref #{source} #{version}")
    end

    def package_name
      "#{name}-#{Rip.md5("#{source}#{path}#{ref || version}")}"
    end

    def fetch
      unless File.directory?(package_path)
        path == "/" ? fetch_without_path : fetch_with_path
      end

      package_path
    end

    def fetch_without_path
      system("git clone #{cache_path} #{package_path} &> /dev/null") || exit(1)
      cd package_path
      system("git checkout --quiet #{ref} &> /dev/null")
      system("git remote rm origin &> /dev/null")
      system("git branch -D master &> /dev/null")
    end

    def fetch_with_path
      base_package = sh("rip-fetch #{source} #{ref}")

      unless File.exist?("#{base_package}#{path}")
        abort "#{source} #{path} does not exist"
      end

      ln_s "#{base_package}#{path}", package_path
    end
  end
end
