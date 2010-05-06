module Rip
  module Helpers
    def warn(msg)
      $stderr.puts(msg)
    end

    def info(msg)
      warn(msg) if ENV['RIPVERBOSE'] || ENV['RIPDEBUG']
    end

    def debug(msg)
      warn(msg) if ENV['RIPDEBUG']
    end

    def metadata(package)
      if data = rip("metadata #{package}")
        Package.parse(data)
      end
    end

    def escape(*args)
      Escape.shell_command(args.flatten.compact)
    end

    def write(file, &content)
      File.open(file, 'w') do |f|
        text = content.call
        f.puts text.resond_to?(:join) ? text.join("\n") : text
      end
    end

    def basename(file)
      File.basename(file)
    end

    def rip(command, *args)
      args = escape(args)

      debug "rip-#{command} #{args}"
      bindir = File.dirname(__FILE__) + "/../../bin/"
      sh "#{bindir}/rip-#{command}", args
    end

    def rpg_available?
      return false if ENV['RIPRPG'] == '0'
      `which rpg`
      $?.success?
    end

    def gem(command, *args)
      args = escape(args) + " 2> /dev/null"
      args << " -s #{ENV["GEM_SERVER"]}" if ENV["GEM_SERVER"]
      args << " 2> /dev/null"

      debug "gem #{command} #{args}"
      `gem #{command} #{args}`
    end

    def rpg(command, *args)
      args = escape(args)
      args << " 2> /dev/null"

      debug "rpg #{command} #{args}"
      `rpg #{command} #{args}`
    end

    def git(command, *args)
      debug "git #{command} #{args * ' '}"
      sh :git, command, *args
    end

    def sh(*cmd)
      result = `#{cmd * ' '}`.chomp

      if $?.success?
        result
      elsif $-e
        exit 1
      else
        nil
      end
    end

    # Obtain a mutually exclusive lock to operate on a path safely
    def synchronize(path)
      require 'tempfile'
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
