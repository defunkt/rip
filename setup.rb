#
# installs rip like so:
#   ruby setup.rb
#
# also uninstalls rip like so:
#   ruby setup.rb uninstall
#
# probably requires sudo.
#

__DIR__ = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift File.join(__DIR__, 'lib')

require 'rip'

include Rip::Setup

if ARGV.include? 'uninstall'
  uninstall :verbose
elsif installed?
  puts "rip: already installed"
else
  install_libs
  install_binary
  setup_startup_script
  finish_setup
end
