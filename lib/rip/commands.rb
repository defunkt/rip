module Rip
  module Commands
    extend self

    def help(options = {}, command = nil, *args)
      case command.to_s
      when 'env'
        show_help 'env', Rip::Env.commands
      else
        show_help nil, public_instance_methods
      end
    end

    def check(*args)
      Setup.check_installation
      puts "rip: all systems go"
    rescue => e
      abort "rip: installation failed. #{e.message}"
    end

    def install(options = {}, *args)
    end

    def uninstall(options = {}, *args)
    end

    def env(options = {}, command = nil, *args)
      if command
        Rip::Env.new.call(command, *args)
      else
        help nil, :env
      end
    end

  private
    def show_help(command, commands)
      subcommand = command.to_s.empty? ? nil : "#{command} "
      puts "Usage: rip #{subcommand}COMMAND [options]", ""
      puts "Commands available:"

      commands.each do |method|
        puts "  #{method}"
      end
    end
  end
end
