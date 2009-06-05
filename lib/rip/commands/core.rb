module Rip
  module Commands
    def list(*args)
      ui.puts 'ripenv: ' + Rip::Env.active, ''
      ui.puts manager.packages
    end

    def help(options = {}, command = nil, *args)
      command = command.to_s
      if help = @help[command.downcase]
        ui.puts "Usage: %s" % (@usage[command] || "rip #{command.downcase}")
        ui.puts
        ui.puts(*help)
      else
        show_general_help
      end
    end

    def env(options = {}, command = nil, *args)
      if command && Rip::Env.respond_to?(command)
        ui.puts 'ripenv: ' + Rip::Env.call(command, *args).to_s
      else
        help nil, :env
      end
    end

    o 'rip freeze [env]'
    x 'Outputs all the installed libraries and their version.'
    x 'Accepts a ripenv. If none is given, uses the active env.'
    def freeze(options = {}, env = nil, *args)
      manager(env).packages.each do |package|
        ui.puts "#{package.source} #{package.version}"
      end
    end

    x 'Prints the current version and exits.'
    def version(options = {}, *args)
      puts Rip::Version
    end
    alias_method        "-v", :version
    alias_method "--version", :version

  private
    def show_help(command, commands)
      subcommand = command.to_s.empty? ? nil : "#{command} "
      ui.puts "Usage: rip #{subcommand}COMMAND [options]", ""
      ui.puts "Commands available:"

      commands.each do |method|
        ui.puts "  #{method}"
      end
    end

    def show_general_help
      commands = public_instance_methods.reject do |method|
        method =~ /-/ || %w( help version ).include?(method)
      end

      show_help nil, commands

      ui.puts
      ui.puts "For more information on a a command use:"
      ui.puts "  rip help COMMAND"
      ui.puts

      ui.puts "Options: "
      ui.puts "  -h, --help     show this help message and exit"
      ui.puts "  -v, --version  show the current version and exit"
    end
  end
end
