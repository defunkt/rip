require 'tempfile'

module Rip
  module Helpers
    def debug(msg)
      warn(msg) if ENV['RIPDEBUG']
    end

    def rip(command, *args)
      bindir = File.dirname(__FILE__) + "/../../bin/"
      sh "#{bindir}/rip-#{command}", *args
    end

    def rpg_available?
      `which rpg`
      $?.success?
    end

    def gem(command, *args)
      args << "-s #{ENV["GEM_SERVER"]}" if ENV["GEM_SERVER"]
      args << "2> /dev/null"

      `gem #{command} #{args * ' '}`
    end

    def rpg(command, *args)
      args << "2> /dev/null"

      `rpg #{command} #{args * ' '}`
    end

    def git(command, *args)
      sh :git, command, *args
    end

    def sh(*cmd)
      options = cmd.last.is_a?(Hash) ? cmd.pop : {}
      result = `#{cmd * ' '}`.chomp

      if $?.success?
        result
      else
        # Err, this sucks, maybe exit 1 shouldn't
        # be the default option
        #
        # I agree.
        if options[:exit] == false
          false
        else
          exit 1
        end
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
