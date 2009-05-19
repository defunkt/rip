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

    def install(options = {}, target = nil, *args)
      if target.to_s.empty?
        abort "rip: please tell me what to install"
      end

      Rip::Package.new(target).install
    end

    def uninstall(options = {}, *args)
    end

    def env(options = {}, command = nil, *args)
      env = Rip::Env.new
      if command && env.respond_to?(command)
        puts "ripenv: " + Rip::Env.new.call(command, *args).to_s
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
