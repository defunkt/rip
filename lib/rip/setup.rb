require 'rbconfig'
require 'fileutils'

module Rip
  module Setup
    extend self


    #
    # config
    #

    WEBSITE = "http://hellorip.com/"
    STARTUP_SCRIPTS = %w( .bash_profile .bash_login .bashrc .zshenv .profile .zshrc )
    FISH_STARTUP_SCRIPT = ".config/fish/config.fish"

    __DIR__ = File.expand_path(File.dirname(__FILE__))

    HOME = File.expand_path('~')

    USER = ENV['USER']

    # Work around Apple's Ruby.
    #
    BINDIR = if defined? RUBY_FRAMEWORK_VERSION
               File.join("/", "usr", "bin")
             else
               RbConfig::CONFIG["bindir"]
             end

    LIBDIR = RbConfig::CONFIG['sitelibdir']

    RIPDIR = File.expand_path(ENV['RIPDIR'] || File.join(HOME, '.rip'))
    RIPROOT = File.expand_path(File.join(__DIR__, '..', '..'))
    RIPINSTALLDIR = File.join(LIBDIR, 'rip')


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
      setup_startup_script
      finish_setup
    end

    def upgrade
      remove_libs
      install_libs
      ui.puts "rip upgraded"
    end

    def uninstall(verbose = false)
      FileUtils.rm File.join(BINDIR, 'rip'), :verbose => verbose
      remove_libs verbose
      FileUtils.rm_rf RIPDIR, :verbose => verbose

      # just in case...
      gembin = ENV['GEMBIN'] || 'gem'
      `#{gembin} uninstall rip 2&> /dev/null`

      ui.abort "rip uninstalled" if verbose
    rescue Errno::EACCES
      ui.abort "uninstall failed. please try again with `sudo`" if verbose
    rescue Errno::ENOENT
      nil
    rescue => e
      raise e if verbose
    end

    def remove_libs(verbose = false)
      FileUtils.rm_rf RIPINSTALLDIR, :verbose => verbose
      FileUtils.rm_rf File.join(LIBDIR, 'rip.rb'), :verbose => verbose
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
        FileUtils.cp src, dst, :verbose => verbose, :preserve => true
        FileUtils.chmod(0755, dst)

        ruby_bin = File.expand_path(File.join(BINDIR, RbConfig::CONFIG['ruby_install_name']))
        if File.exist? ruby_bin
          ui.puts "rip: using Ruby bin: #{ruby_bin}"
          rewrite_bang_line(dst, "#!#{ruby_bin}")
        end
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
    # Returns whether a startup script has been modified. If one of
    # the startup scripts already contain the Rip configuration
    # statements, then nothing will be modified and false will be
    # returned.
    #
    # TODO: Requires the startup script, but probably acceptable for most? --rue
    #
    def setup_startup_script(script = nil)
      if script
        script = File.expand_path(script)
      else
        script = startup_script
      end

      if script.empty? || !File.exists?(script)
        ui.puts "rip: please create one of these startup scripts in $HOME and re-run:"
        ui.abort STARTUP_SCRIPTS.map { |s| '  ' + s }
      end

      if !ENV['RIPDIR'].to_s.empty?
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

      Rip needs certain env variables to run. We've tried
      to install them automatically but may have failed.

      Run `rip check` to check the status of your
      installation.

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
          raise StaleEnvironmentError, <<-end_error
No $RIPDIR. Rip has been integrated into your shell startup scripts but your
shell hasn't yet picked up the changes.

To complete the installation process please restart your shell or run:
  source #{startup_script}
end_error
        else
          raise InstallationError, <<-end_error
No $RIPDIR. Rip hasn't been integrated into your shell startup scripts yet.
Please run `rip setup` to do so.
end_error
        end
      end

      if !expand_paths(ENV['PATH'].split(':')).include?('rip')
        raise InstallationError, "no rip in #{ENV['PATH']}"
      end

      if !expand_paths($LOAD_PATH).include?('rip')
        raise InstallationError, "no rip in #{$LOAD_PATH.join(":")}"
      end

      if !expand_paths($LOAD_PATH).include?('rip.rb')
        raise InstallationError, "no rip.rb in #{$LOAD_PATH.join(":")}"
      end

      true
    end

    def expand_paths(paths)
      paths.map { |path| Dir["#{path}/*"] }.flatten.map { |path| File.basename(path) }.uniq
    end

    def rewrite_bang_line(file, first_line)
      lines = File.readlines(file)[1..-1]
      File.open(file, 'w') do |f|
        f.puts first_line
        f.puts lines.join
        f.flush
      end
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
