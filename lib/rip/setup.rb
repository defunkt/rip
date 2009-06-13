require 'rbconfig'
require 'fileutils'

module Rip
  module Setup
    extend self


    #
    # config
    #

    WEBSITE = "http://hellorip.com/"
    STARTUP_SCRIPTS = %w( .bash_profile .bash_login .bashrc .zshrc .profile .zshenv )
    FISH_STARTUP_SCRIPT = ".config/fish/config.fish"

    __DIR__ = File.expand_path(File.dirname(__FILE__))

    HOME = File.expand_path('~')
    USER = HOME.split('/')[-1]
    LIBDIR = RbConfig::CONFIG['sitelibdir']
    RIPDIR = File.expand_path(ENV['RIPDIR'] || File.join(HOME, '.rip'))
    RIPROOT = File.expand_path(File.join(__DIR__, '..', '..'))
    RIPINSTALLDIR = File.join(LIBDIR, 'rip')

    # caution: RbConfig::CONFIG['bindir'] does NOT work for me
    # on OS X
    BINDIR = File.join('/', 'usr', 'local', 'bin')

    # Indicates that Rip isn't properly installed.
    class InstallationError < StandardError; end

    # Indicates that Rip is properly installed, but the current shell
    # hasn't picked up the installed Rip environment variables yet. The
    # shell must be restarted for the changes to become effective, or
    # the shell startup files must be re-sourced.
    class StaleEnvironmentError < StandardError; end


    #
    # setup steps
    #

    def install
      install_libs
      install_binary
      setup_ripenv
      finish_setup
    end

    def uninstall(verbose = false)
      FileUtils.rm_rf RIPINSTALLDIR, :verbose => verbose
      FileUtils.rm_rf File.join(LIBDIR, 'rip.rb'), :verbose => verbose
      FileUtils.rm_rf RIPDIR, :verbose => verbose
      FileUtils.rm File.join(BINDIR, 'rip'), :verbose => verbose

      # just in case...
      `gem uninstall rip 2&> /dev/null`

      ui.abort "rip uninstalled" if verbose
    rescue Errno::EACCES
      ui.abort "rip: uninstall failed. please try again with `sudo`" if verbose
    rescue Errno::ENOENT
      nil
    rescue => e
      raise e if verbose
    end

    def install_libs(verbose = false)
      transaction "installing library files" do
        riprb = File.join(RIPROOT, 'lib', 'rip.rb')
        ripdr = File.join(RIPROOT, 'lib', 'rip')
        FileUtils.cp_r riprb, LIBDIR, :verbose => verbose
        FileUtils.cp_r ripdr, LIBDIR, :verbose => verbose
      end
    end

    def install_binary(verbose = false)
      transaction "installing rip binary" do
        src = File.join(RIPROOT, 'bin', 'rip')
        dst = File.join(BINDIR, 'rip')
        FileUtils.cp src, dst, :verbose => verbose
      end
    end

    def setup_ripenv(ripdir=RIPDIR, verbose = false)
      transaction "setting up ripenv" do
        FileUtils.mkdir_p File.join(ripdir, 'rip-packages')
        Rip.dir = ripdir
        Rip::Env.create 'base'
        FileUtils.chown_R USER, nil, ripdir, :verbose => verbose
      end
    end

    # Modifies the shell startup script(s) and inserts the Rip
    # configuration statements.
    #
    # This is not called by default by 'setup.rb' in the top-level
    # Rip sources; instead, the user is supposed to run 'rip setup'.
    #
    # Returns wheter a startup script has been modified. If one of
    # the startup scripts already contain the Rip configuration
    # statements, then nothing will be modified and false will be
    # returned.
    #
    # TODO: Requires the startup script, but probably acceptable for most? --rue
    #
    def setup_startup_script
      script = startup_script

      if script.empty?
        ui.puts "rip: please create one of these startup scripts in $HOME and re-run:"
        ui.puts STARTUP_SCRIPTS.map { |s| '  ' + s }
        exit
      end

      if File.read(script).include? 'RIPDIR='
        ui.puts "rip: env variables already present in startup script"
        false
      else
        ui.puts "rip: adding env variables to #{script}"
        File.open(script, 'a+') do |f|
          f.puts startup_script_template
        end
        true
      end
    end

    def finish_setup
      ui.puts finish_setup_banner(startup_script)
    end

    def finish_setup_banner(script = "~/.bash_profile")
      <<-EOI.gsub(/^ +/, "")
      ****************************************************
      So far so good...

      You should define some environment variables. You can
      run `rip setup` to automatically insert them into your
      startup script (#{script}). You need:

      #{startup_script_template}

      Run `rip check` after setting up to verify that Rip
      installed successfully

      Get started: `rip -h` or #{WEBSITE}

      ****************************************************
      EOI
    end

    #
    # helper methods
    #

    def transaction(message, &block)
      ui.puts 'rip: ' + message
      block.call
    rescue Errno::EACCES
      uninstall
      ui.abort "access denied. please try running again with `sudo`"
    rescue => e
      ui.puts "rip: something failed, rolling back..."
      uninstall
      raise e
    end

    def startup_script_template
      (fish? ? FISH_CONFIG_TEMPLATE : STARTUP_SCRIPT_TEMPLATE) % RIPDIR
    end

    def startup_script
      script = fish_startup_script || STARTUP_SCRIPTS.detect do |script|
        File.exists? file = File.join(HOME, script)
      end

      script ? File.join(HOME, script) : ''
    end

    def startup_script_contains_rip_configuration?
      filename = startup_script
      !filename.empty? && File.read(filename).include?(startup_script_template)
    end

    def fish_startup_script
      FISH_STARTUP_SCRIPT if fish?
    end

    def fish?
      File.exists?(File.join(HOME, FISH_STARTUP_SCRIPT))
    end

    def installed?
      check_installation
      true
    rescue
      false
    end

    def check_installation
      if ENV['RIPDIR'].to_s.empty?
        if startup_script_contains_rip_configuration?
          raise StaleEnvironmentError,
                "No $RIPDIR. Rip has already been integrated into your shell startup scripts, " +
                "but your shell hasn't picked up the changes yet. Please restart your shell for " +
                "the integration to become effective, or type `source #{startup_script}`."
        else
          raise InstallationError,
                "No $RIPDIR. Rip hasn't been integrated into your shell startup scripts yet; " +
                "please run `rip setup` to do so."
        end
      end

      if !File.exists? File.join(BINDIR, 'rip')
        raise InstallationError, "no rip in #{BINDIR}"
      end

      if !File.exists? File.join(LIBDIR, 'rip')
        raise InstallationError, "no rip in #{LIBDIR}"
      end

      if !File.exists? File.join(LIBDIR, 'rip')
        raise InstallationError, "no rip.rb in #{LIBDIR}"
      end

      true
    end

    def ui
      Rip.ui
    end
  end

  STARTUP_SCRIPT_TEMPLATE = <<-end_template

# -- start rip config -- #
RIPDIR=%s
RUBYLIB="$RUBYLIB:$RIPDIR/active/lib"
PATH="$PATH:$RIPDIR/active/bin"
export RIPDIR RUBYLIB PATH
# -- end rip config -- #
end_template

  FISH_CONFIG_TEMPLATE = <<-end_template
# -- start rip config -- #
set -x RIPDIR %s
set -x RUBYLIB "$RUBYLIB:$RIPDIR/active/lib"
set PATH $RIPDIR/active/bin $PATH
# -- end rip config -- #
end_template

end
