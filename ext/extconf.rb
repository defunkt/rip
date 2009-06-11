#
# rip needs some magic to get working.
# this is, as they say, where the magic happens.
#

__DIR__ = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift File.join(__DIR__, '..')

File.open('Makefile', 'w') { |f| f.puts("install:\n\t$(echo ok)") }

require 'setup'
