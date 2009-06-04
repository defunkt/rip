module Rip
  module Commands
    def list(*args)
      ui.puts 'ripenv: ' + Rip::Env.active, ''
      ui.puts manager.packages
    end

    def help(options = {}, command = nil, *args)
      case command.to_s
      when 'env'
        show_help 'env', Rip::Env.commands
      else
        show_help nil, public_instance_methods
      end
    end

    def env(options = {}, command = nil, *args)
      if command && Rip::Env.respond_to?(command)
        ui.puts 'ripenv: ' + Rip::Env.call(command, *args).to_s
      else
        help nil, :env
      end
    end

    def freeze(options = {}, *args)
      manager.packages.each do |package|
        ui.puts "#{package.source} #{package.version}"
      end
    end

  private
    def show_help(command, commands)
      subcommand = command.to_s.empty? ? nil : "#{command} "
      ui.puts "Usage: rip #{subcommand}COMMAND [options]", ""
      ui.puts "Commands available:"

      commands.each do |method|
        ui.puts "  #{method}"
      end
    end
  end
end
