module Rip
  module Commands
    x 'Display libraries installed in the current ripenv.'
    def list(*args)
      ui.puts 'ripenv: ' + Rip::Env.active, ''
      if manager.packages.any?
        ui.puts manager.packages.sort_by { |p| p.to_s }
      else
        ui.puts "nothing installed"
      end
    end

    def help(options = {}, command = nil, *args)
      command = command.to_s
      if !command.empty? && respond_to?(command)
        ui.puts "Usage: %s" % (@usage[command] || "rip #{command.downcase}")
        if @help[command]
          ui.puts
          ui.puts(*@help[command])
        end
      else
        show_general_help
      end
    end

    o 'rip env COMMAND'
    x 'Commands for managing your ripenvs.'
    x 'Type rip env to see valid options.'
    def env(options = {}, command = nil, *args)
      if command && Rip::Env.commands.include?(command)
        args.push(options)
        ui.puts 'ripenv: ' + Rip::Env.call(command, *args).to_s
      else
        Rip::Env.show_help :env
        ui.puts '', "current ripenv: #{Rip::Env.active}"
      end
    end

    o 'rip use RIPENV'
    x 'Activates a ripenv. Shortcut for `rip env use`.'
    def use(options = {}, ripenv = nil, *args)
      puts 'ripenv: ' + Rip::Env.use(ripenv.to_s)
    end

    x 'Outputs all installed libraries (and their versions) for the active env.'
    x 'Can be saved as a .rip and installed by other rip users with:'
    x '  rip install file.rip'
    def freeze(options = {}, env = nil, *args)
      manager(env).packages.each do |package|
        ui.puts "#{package.source} #{package.version}"
      end
    end

    x 'Prints the current version and exits.'
    def version(options = {}, *args)
      ui.puts "Rip #{Rip::Version}"
    end

  private
    def show_general_help
      commands = public_instance_methods.reject do |method|
        method =~ /-/ || %w( help version ).include?(method)
      end

      show_help nil, commands.sort

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
