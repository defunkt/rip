# installs rip

#
# -- step 0 --
# setup config
#

require 'fileutils'
require 'rbconfig'

__DIR__ = File.expand_path(File.dirname(__FILE__))

HOME = File.expand_path('~')
LIBDIR = RbConfig::CONFIG['sitelibdir']
BINDIR = RbConfig::CONFIG['bindir']
RIPDIR = File.join(HOME, '.rip')
RIPLIBDIR = File.join(LIBDIR, 'rip')

def transaction(message, &block)
  begin
    puts "rip: #{message}"
    block.call
  rescue => e
    puts "rip: something failed, rolling back..."

    begin
      FileUtils.rm_rf RIPLIBDIR
      FileUtils.rm_rf File.join(RIPLIBDIR, 'rip.rb')
      FileUtils.rm File.join(BINDIR, 'rip')
    rescue
    end

    if e.class == Errno::EACCES
      puts "rip: access denied. please try running again with `sudo`"
    else
      raise e
    end
  end
end

#
# -- step 1 --
# append to the startup script
#

startup_script_template = <<-end_template

# -- start rip config -- #
RIPDIR=#{RIPDIR}
export RIPDIR
RUBYLIB="$RUBYLIB:$RIPDIR/active/lib"
export RUBYLIB
PATH="$PATH:$RIPDIR/active/lib"
export PATH
# -- end rip config -- #

end_template

startup_scripts = %w( .profile .bash_profile .bashrc .zshrc )
startup_script = startup_scripts.detect do |script|
  File.exists? File.join(HOME, script)
end

if startup_script
  startup_script = File.join(HOME, startup_script)
else
  puts "rip: please create one of these startup scripts in ~:"
  puts startup_scripts.map { |s| '  ' + s }
  exit
end

puts "rip: adding env variables to #{startup_script}"
# File.open(startup_script, 'a+') do |f|
#   f.puts startup_script_template
# end


#
# -- step 2 --
# add rip libraries to siteLIBDIR
#

transaction "installing library files" do
  FileUtils.cp_r File.join(__DIR__, 'lib', 'rip.rb'), LIBDIR, :verbose => true
  FileUtils.cp_r File.join(__DIR__, 'lib', 'rip'), LIBDIR, :verbose => true
end


#
# -- step 3 --
# add rip binary to BINDIR
#

transaction "installing rip binary" do
  FileUtils.cp File.join(__DIR__, 'bin', 'rip.rb'), BINDIR, :verbose => true
end
