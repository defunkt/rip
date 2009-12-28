ripdir = ENV['RIPDIR']

if ripdir.to_s.empty?
  abort "$RIPDIR not set. Please eval `rip-shell`"
end

RIPDIR = File.expand_path(ripdir)
RIPENV = ENV['RIPENV'] || File.basename(File.readlink("#{RIPDIR}/active"))

require 'fileutils'
include FileUtils
