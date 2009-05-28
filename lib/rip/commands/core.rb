module Rip
  module Commands
    def list(*args)
      puts "ripenv: #{Rip::Env.active}", ''
      puts manager.packages.map { |package| "#{package} (#{package.version})" }
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
