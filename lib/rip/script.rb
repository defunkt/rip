require 'rip'

check = `rip-check`

if $?.success?
  check.split("\n").each do |line|
    const, value = line.split("=")

    if const == 'RIPDIR'
      Rip.dir = value
    elsif const == 'RIPENV'
      Rip.env = value
    end
  end
else
  print check
  exit 1
end

RIPDIR     = Rip.dir
RIPENV     = Rip.env
RIPENVS    = Rip.envs
CACHEDIR   = Rip.cache
PACKAGEDIR = Rip.packages
ACTIVEDIR  = Rip.active

require 'fileutils'
include FileUtils

def rip(command, *args)
  bindir = File.dirname(__FILE__) + "/../../bin/"
  `#{bindir}/rip-#{command} #{args.join(' ')}`
end
