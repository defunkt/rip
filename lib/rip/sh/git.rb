module Rip
  module Sh
    module Git
      extend self

      def git_ls_remote(source, version)
        `git ls-remote #{source} #{version} 2> /dev/null`
      end

      def git_clone(source, cache_name)
        `git clone #{source} #{cache_name}`
      end

      def git_fetch(remote)
        `git fetch #{remote}`
      end

      def git_reset_hard(version)
        raise "FUCK"
        `git reset --hard #{version}`
      end

      def git_submodule_init
        `git submodule init`
      end

      def git_submodule_update
        `git submodule update`
      end

      def git_revparse(repothing)
        `git rev-parse #{repothing}`
      end
    end
  end
end
