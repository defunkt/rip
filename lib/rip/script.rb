ripdir = ENV['RIPDIR']

# We could guess that the $RIPDIR is $HOME, but then they probably
# don't have their RUBYLIB or PATH variables setup properly,
# either. Checking $RIPDIR ensures they at least know what they're
# doing.
if ripdir.to_s.empty?
  abort "$RIPDIR not set. Please eval `rip-shell`"
end

# rip-create is the only rip command that may operate without a
# $RIPDIR. Everyone else fails here if one isn't found.
script = File.basename($0)
if script != 'rip-create' && !File.exists?(ripdir = File.expand_path(ripdir))
  abort "#{ripdir} not found. Please run `rip-setup`"
end

RIPDIR  = File.expand_path(ripdir)
RIPENV  = ENV['RIPENV'] || File.basename(File.readlink("#{RIPDIR}/active"))
RIPENVS = Dir["#{RIPDIR}/*"].map { |f| File.basename(f) }.reject do |ripenv|
  ripenv == 'active' || ripenv[0].chr == '.'
end

require 'fileutils'
include FileUtils

require 'rip'
include Rip

def rip(command, *args)
  bindir = File.dirname(__FILE__) + "/../../bin/"
  exec "#{bindir}/rip-#{command}", *args
end
