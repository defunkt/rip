$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')

require 'rip'
Rip.dir = File.expand_path(File.join(File.dirname(__FILE__), 'ripdir'))
Rip::Env.use 'base'

require 'mocha'
require 'test/spec/mini'

begin
  require 'redgreen'
rescue LoadError
end

def mock_fileutils!
  Object.send(:remove_const, :FileUtils) # squash warnings
  Object.const_set(:FileUtils, mock)
end

def stub_fileutils!
  Object.send(:remove_const, :FileUtils) # squash warnings
  Object.const_set(:FileUtils, stub_everything)
end
