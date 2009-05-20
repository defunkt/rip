require 'rbconfig'
require 'fileutils'

module Rip
  module Setup
    extend self


    #
    # config
    #

    WEBSITE = "http://defunkt.github.com/rip"
    STARTUP_SCRIPTS = %w( .bash_profile .bash_login .bashrc .zshrc .profile )

    __DIR__ = File.expand_path(File.dirname(__FILE__))

    HOME = File.expand_path('~')
    USER = HOME.split('/')[-1]
    LIBDIR = RbConfig::CONFIG['sitelibdir']
    RIPDIR = File.join(HOME, '.rip')
    RIPROOT = File.expand_path(File.join(__DIR__, '..', '..'))
    RIPINSTALLDIR = File.join(LIBDIR, 'rip')

    # caution: RbConfig::CONFIG['bindir'] does NOT work for me
    # on OS X
    BINDIR = File.join('/', 'usr', 'local', 'bin')


    #
    # setup steps
    #

    def install
      install_libs
      install_binary
      setup_ripenv
      setup_startup_script
      finish_setup
    end

    def uninstall(verbose = false)
      FileUtils.rm_rf RIPINSTALLDIR, :verbose => verbose
      FileUtils.rm_rf File.join(LIBDIR, 'rip.rb'), :verbose => verbose
      FileUtils.rm_rf RIPDIR, :verbose => verbose
      FileUtils.rm File.join(BINDIR, 'rip'), :verbose => verbose
      abort "rip uninstalled" if verbose
    rescue Errno::EACCES
      abort "rip: uninstall failed. please try again with `sudo`" if verbose
    rescue Errno::ENOENT
      nil
    rescue => e
      raise e if verbose
    end

    def install_libs
      transaction "installing library files" do
        riprb = File.join(RIPROOT, 'lib', 'rip.rb')
        ripdr = File.join(RIPROOT, 'lib', 'rip')
        FileUtils.cp_r riprb, LIBDIR, :verbose => true
        FileUtils.cp_r ripdr, LIBDIR, :verbose => true
      end
    end

    def install_binary
      transaction "installing rip binary" do
        src = File.join(RIPROOT, 'bin', 'rip.rb')
        dst = File.join(BINDIR, 'rip')
        FileUtils.cp src, dst, :verbose => true
      end
    end

    def setup_ripenv
      transaction "setting up ripenv" do
        FileUtils.mkdir_p File.join(RIPDIR, 'rip-packages')
        Rip.dir = RIPDIR
        Rip::Env.create 'base'
        FileUtils.chown_R USER, nil, RIPDIR, :verbose => true
      end
    end

    def setup_startup_script
      script = startup_script

      if script.empty?
        puts "rip: please create one of these startup scripts in $HOME:"
        puts startup_scripts.map { |s| '  ' + s }
        exit
      end

      if File.read(script).include? 'RIPDIR='
        puts "rip: env variables already present in startup script"
      else
        puts "rip: adding env variables to #{script}"
        File.open(script, 'a+') do |f|
          f.puts startup_script_template
        end
      end
    end

    def finish_setup
      puts ''
      puts "rip has been successfully installed"
      puts "validate the installation process by running `rip check`"
      puts ''
      puts "get started: see `rip -h` or #{WEBSITE}"
    end


    #
    # helper methods
    #

    def transaction(message, &block)
      puts "rip: #{message}"
      block.call
    rescue Errno::EACCES
      uninstall
      abort "rip: access denied. please try running again with `sudo`"
    rescue => e
      puts "rip: something failed, rolling back..."
      uninstall
      raise e
    end

    def startup_script_template
      STARTUP_SCRIPT_TEMPLATE % RIPDIR
    end

    def startup_script
      script = STARTUP_SCRIPTS.detect do |script|
        File.exists? file = File.join(HOME, script)
      end

      script ? File.join(HOME, script) : ''
    end

    def installed?
      check_installation
      true
    rescue
      false
    end

    def check_installation
      script = startup_script

      if !File.read(script).include? 'RIPDIR='
        raise "no env variables in startup script"
      end

      if ENV['RIPDIR'].to_s.empty?
        if startup_script.empty?
          raise "no $RIPDIR."
        else
          raise "no $RIPDIR. you may need to run `source #{startup_script}`"
        end
      end

      if !File.exists? File.join(BINDIR, 'rip')
        raise "no rip in #{BINDIR}"
      end

      if !File.exists? File.join(LIBDIR, 'rip')
        raise "no rip in #{LIBDIR}"
      end

      if !File.exists? File.join(LIBDIR, 'rip')
        raise "no rip.rb in #{LIBDIR}"
      end

      true
    end
  end

  STARTUP_SCRIPT_TEMPLATE = <<-end_template

# -- start rip config -- #
RIPDIR=%s
export RIPDIR
RUBYLIB="$RUBYLIB:$RIPDIR/active/lib"
export RUBYLIB
PATH="$PATH:$RIPDIR/active/bin"
export PATH
# -- end rip config -- #
end_template

end
