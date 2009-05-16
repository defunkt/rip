module Rip
  module Commands
    extend self

    def help(*args)
      puts "Usage: rip COMMAND [options]", ""
      puts "Commands available:"

      instance_methods.each do |method|
        puts "  #{method}"
      end
    end

    def install(options = {}, *args)
      puts :woot
      puts options.inspect
      puts args.inspect
    end

    def uninstall(options = {}, *args)
      puts :toow
    end

    def env(options, command, name = nil)
      puts command
    end
  end
end
