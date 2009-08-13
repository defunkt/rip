module Rip
  class GitPackage < Package
    include Sh::Git

    handles "file://", "git://", '.git'

    memoize :name
    def name
      source.split('/').last.chomp('.git')
    end

    def version
      return @version if @version

      fetch!
      Dir.chdir cache_path do
        @version = git_rev_parse('origin/master')[0,7]
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
          git_fetch('origin')
        end
      else
        git_clone(source, cache_path)
      end
    end

    def unpack!
      Dir.chdir cache_path do
        git_reset_hard version_is_branch? ? "origin/#{version}" : version
        git_submodule_init
        git_submodule_update
      end
    end

  private
    def file_exists?
      File.exists? File.join(source.sub('file://', ''), '.git')
    end

    def remote_exists?
      return false if git_ls_remote(source).size == 0
      return true if !@version

      fetch
      Dir.chdir(cache_path) do
        git_cat_file(@version).size > 0 || version_is_branch?
      end
    end

    def version_is_branch?
      git_cat_file("origin/#{version}").size > 0
    end
  end
end
