module Rip
  module Commands
    def check(*args)
      Setup.check_installation
      puts "All systems go."
    rescue => e
      abort "Installation failed: #{e.message}"
    end

    def install(options = {}, source = nil, version = nil, *args)
      if source.to_s.empty?
        abort "Please tell me what to install."
      end

      package = Rip::Package.for(source, version)

      if !package
        abort "I don't know how to install #{source}"
      end

      if options[:f]
        Installer.new.uninstall(package) if package.installed?
        Installer.new.install(package)
      elsif package.installed?
        puts "#{package} already installed"
      else
        installer = Installer.new
        installer.install(package)
        puts "#{installer.installed.size.to_i} packages installed"
      end
    end
  end
end
