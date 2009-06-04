module Rip
  module Commands
    def list(*args)
      puts "ripenv: #{Rip::Env.active}", ''
      puts manager.packages
    end

    def help(options = {}, command = nil, *args)
      case command.to_s
      when 'env'
        show_help 'env', Rip::Env.commands
      else
        show_general_help
      end
    end

    def env(options = {}, command = nil, *args)
      if command && Rip::Env.respond_to?(command)
        puts "ripenv: " + Rip::Env.call(command, *args).to_s
      else
        help nil, :env
      end
    end

    def freeze(options = {}, *args)
      manager.packages.each do |package|
        puts "#{package.source} #{package.version}"
      end
    end

    def version(options = {}, *args)
      puts Rip::Version
    end
    alias_method        "-v", :version
    alias_method "--version", :version

  private
    def show_help(command, commands)
      subcommand = command.to_s.empty? ? nil : "#{command} "
      puts "Usage: rip #{subcommand}COMMAND [options]", ""
      puts "Commands available:"

      commands.each do |method|
        puts "  #{method}"
      end
    end

    def show_general_help
      commands = public_instance_methods.reject do |method|
        method =~ /-/ || %w( help version ).include?(method)
      end

      show_help nil, commands

      puts
      puts "For more information on a a command use:"
      puts "  rip help COMMAND"
      puts

      puts "Options: "
      puts "  -h, --help     show this help message and exit"
      puts "  -v, --version  show the current version and exit"
    end
  end
end
