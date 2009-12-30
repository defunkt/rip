ripdir  = ENV['RIPDIR']
ripenv  = ENV['RIPENV']

RIPDIR  = ripdir ? File.expand_path(ripdir) : nil
RIPENV  = ripenv ? ripenv : File.basename(File.readlink("#{RIPDIR}/active"))
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
