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

require "rip"

include Rip::Setup

# TODO: Use, like, real option parsing. --rue

%w( bindir libdir ripdir ).each do |opt|
  if given = ARGV.grep(/--#{opt}=\S+/).last
    Rip::Setup.const_set(opt.upcase, File.expand_path(given.split("=").last))
  end
end

if ARGV.include? 'uninstall'
  uninstall :verbose
elsif ARGV.include? 'reinstall'
  uninstall
  install
elsif installed?
  puts "rip: already installed"
else
  install
end

