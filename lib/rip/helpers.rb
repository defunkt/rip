require 'tempfile'

module Rip
  module Helpers
    def rip(command, *args)
      bindir = File.dirname(__FILE__) + "/../../bin/"
      sh "#{bindir}/rip-#{command}", *args
    end

    def gem(command, *args)
      args << "-s #{ENV["GEM_SERVER"]}" if ENV["GEM_SERVER"]
      sh "gem", command, *args
    end

    def git(command, *args)
      sh :git, command, *args
    end

    def sh(*cmd)
      result = `#{cmd * ' '}`.chomp

      if $?.success?
        result
      else
        exit 1
      end
    end

    # Obtain a mutually exclusive lock to operate on a path safely
    def synchronize(path)
      path = File.join(Dir.tmpdir, "#{Rip.md5(path)}.lock")
      file = File.new(path, 'w+')
      file.flock(File::LOCK_EX)
      yield
    ensure
      file.flock(File::LOCK_UN)
      file.close
      # We can't safely cleanup the lock file. This litters tmp with
      # lock files. Not a big deal but we could do better.
    end
  end
end
