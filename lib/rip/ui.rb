module Rip
  class UI
    def initialize(io = nil, verbose = false)
      @io = io
      @verbose = verbose
    end

    def puts(*args)
      return unless @io

      if args.empty?
        @io.puts ""
      else
        args.each { |msg| @io.puts(msg) }
      end

      @io.flush
      nil
    end

    def abort(msg)
      @io && Kernel.abort("rip: #{msg}")
    end

    def exit(msg)
      @io && puts("rip: #{msg}")
      Kernel.exit
    end

    def vputs(*args)
      puts(*args) if @verbose
    end
  end
end
