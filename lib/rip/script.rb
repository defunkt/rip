check = `rip-check`

if $?.success?
  check.split("\n").each do |line|
    const, value = line.split("=")
    Object.const_set(const, value)
  end
else
  print check
  exit 1
end

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
