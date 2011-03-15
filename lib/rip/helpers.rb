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
      if data = rip("package-metadata #{package}")
        Package.parse(data)
      end
    end

    def escape(*args)
      Escape.shell_command(args.flatten.compact)
    end

    def write(file, &content)
      File.open(file, 'w') do |f|
        text = content.call
        f.puts text.respond_to?(:join) ? text.join("\n") : text
      end
    end

    def read(file)
      File.read(file)
    end

    def basename(file)
      File.basename(file)
    end

    def commands
      @commands ||= lookup_command_cache.split("\n")
    end

    def lookup_command_cache
      ENV['RIPCOMMANDSCACHE'] ||= rip(:commands)
    end

    def rip(command, *args, &block)
      if block_given?
        args << "r"
        rip_io(command, *args) do |io|
          io.each_line do |line|
            block.call(line.chomp)
          end
        end
      else
        args = escape(args)
        debug "rip-#{command} #{args}"
        sh "rip-#{command}", args
      end
    end

    def rip_io(command, *args, &block)
      mode = args.pop
      args = escape(args)

      debug "rip-#{command} #{args}"
      result = IO.popen("rip-#{command} #{args}", mode, &block)

      if $?.success?
        result
      elsif $-e
        exit 1
      else
        nil
      end
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

    def exited_successfully?
      $!.nil? || $!.is_a?(SystemExit) && $!.success?
    end

    # Obtain a mutually exclusive lock to operate on a path safely
    def synchronize(path)
      lockfile = "#{path}.lock"
      file = nil

      loop do
        file = File.new(lockfile, 'a')
        file.flock(File::LOCK_EX)

        # Restat the file and make sure its the same one
        stat = file.stat
        cur_stat = File.stat(lockfile) rescue nil
        if cur_stat &&
            stat.dev == cur_stat.dev &&
            stat.ino == cur_stat.ino
          yield
          break
        end
      end
    ensure
      File.unlink(lockfile) rescue nil
      file.close
    end
  end
end
