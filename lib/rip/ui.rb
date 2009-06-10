module Rip
  class UI
    def initialize(io=nil)
      @io = io
    end

    def puts(*args)
      return unless @io

      if args.empty?
        @io.puts ""
      else
        args.each { |msg| @io.puts(msg) }
      end
    end

    def abort(msg)
      @io && Kernel.abort("rip: #{msg}")
    end
  end
end
