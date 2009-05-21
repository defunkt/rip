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

    def install(options = {}, source = nil, version = nil, *args)
      if source.to_s.empty?
        abort "rip: please tell me what to install"
      end

      package = Rip::Package.for(source, version)

      if options[:f]
        Installer.new.uninstall(package) if package.installed?
        Installer.new.install(package)
      elsif package.installed?
        puts "rip: #{package} already installed"
      else
        Installer.new.install(package)
      end
    end

    def list(*args)
      puts "ripenv: #{Rip::Env.active}", ''
      puts manager.packages.map { |package| "#{package} (#{package.version})" }
    end
    alias_method :installed, :list

    def uninstall(options = {}, name = nil, *args)
      if name.to_s.empty?
        abort "rip: please tell me what to uninstall"
      end

      force = options[:y] || options[:d]
      package = manager.package(name)

      if !package
        abort "rip: #{name} isn't installed"
      end

      dependents = manager.packages_that_depend_on(name)

      if dependents.any? && !force
        puts "rip: the following packages depend on #{name}:"

        dependents.each do |dependent|
          puts "#{dependent} (#{dependent.version})"
        end

        puts "rip: pass -y if you really want to remove #{name}"
        abort "rip: pass -d if you want to remove #{name} and these dependents"
      end

      if force || dependents.empty?
        Installer.new.uninstall(package, options[:d])
      end
    end

    def env(options = {}, command = nil, *args)
      if command && Rip::Env.respond_to?(command)
        puts "ripenv: " + Rip::Env.call(command, *args).to_s
      else
        help nil, :env
      end
    end

  private
    def manager
      @manager ||= PackageManager.new
    end

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


#
# rip plugin commands
#

# load ~/.rip/rip-commands/*.rb
if File.exists? dir = File.join(Rip.dir, 'rip-commands')
  Dir[dir + '/*.rb'].each do |file|
    require file
  end
end

# load lib/rip/commands/*.rb from the active ripenv
if File.exists? dir = File.join(Rip::Env.active_dir, 'lib', 'rip', 'commands')
  Dir[dir + '/*.rb'].each do |file|
    require file
  end
end
