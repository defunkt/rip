module Rip
  class UI
    def initialize(io=nil)
      @io = io
    end

    def puts(*args)
      @io && args.each { |msg| @io.puts(msg) }
    end

    def abort(msg)
      @io && Kernel.abort("rip: #{msg}")
    end
  end
end
