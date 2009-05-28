module Rip
  module Commands
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

      if !package
        abort "rip: don't know how to install #{source}"
      end

      if options[:f]
        Installer.new.uninstall(package) if package.installed?
        Installer.new.install(package)
      elsif package.installed?
        puts "rip: #{package} already installed"
      else
        Installer.new.install(package)
      end
    end
  end
end
