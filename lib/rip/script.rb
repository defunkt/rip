ripdir = ENV['RIPDIR']

if ripdir.to_s.empty?
  abort "$RIPDIR not set. Please eval `rip-shell`"
end

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

require 'rip/db'
require 'rip/package'
include Rip

def rip(command, *args)
  bindir = File.dirname(__FILE__) + "/../../bin/"
  exec "#{bindir}/rip-#{command}", *args
end
