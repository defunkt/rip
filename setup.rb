#
# installs rip like so:
#   ruby setup.rb
#
# upgrades rip like so:
#   ruby setup.rb upgrade
#
# also uninstalls rip like so:
#   ruby setup.rb uninstall
#
# probably requires sudo.
#

__DIR__ = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift File.join(__DIR__, 'lib')

require "rip"
require "optparse"

include Rip::Setup

parser = OptionParser.new
%w( bindir libdir ripdir ).each do |name|
  parser.on("--#{name}=PATH") do |path|
    Rip::Setup.const_set(name.upcase, File.expand_path(path))
  end
end
parser.parse!(ARGV)

if ARGV.include? 'uninstall'
  uninstall :verbose
elsif ARGV.include? 'reinstall'
  uninstall
  install
elsif ARGV.include? 'upgrade'
  upgrade
elsif installed?
  puts "rip: already installed"
else
  install
end

