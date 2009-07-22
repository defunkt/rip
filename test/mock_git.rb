module Rip
  module Sh
    module MockGit
      def git_ls_remote(source, version=nil)
        match_errors = []
        if source != real_source
          match_errors << "source was #{source} instead of #{real_source}"
        end

        if !match_errors.empty?
          raise match_errors.join(" and ")
        end

        "67be542ddad55c502daf12fde4f784d88a248617\tHEAD\n67be542ddad55c502daf12fde4f784d88a248617\trefs/heads/master"
      end

      def git_fetch(repothing)
      end

      def git_clone(source, cache_name)
        match_errors = []
        if source != real_source
          match_errors << "source was #{source} instead of #{real_source}"
        end
        if !match_errors.empty?
          raise match_errors.join(" and ")
        end

        FakeFS::FileSystem.clone(repo_path(real_repo_name))
        FileUtils.mv(repo_path(real_repo_name), cache_name)
      end

      def git_submodule_init
      end

      def git_submodule_update
      end

      def git_reset_hard(version)
      end

      def git_cat_file(object)
        ''
      end

      def real_repo_name
        raise NotImplementedError
      end

      def real_source
        raise NotImplementedError
      end
    end
  end
end
