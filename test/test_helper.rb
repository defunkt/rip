$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')

require 'rip'
Rip.dir = File.expand_path(File.join(File.dirname(__FILE__), 'ripdir'))

require 'fakefs'
require 'test/spec/mini'

begin
  require 'redgreen'
rescue LoadError
end
