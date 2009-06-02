$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')
require 'rip'
Rip.dir = File.expand_path(File.join(File.dirname(__FILE__), 'ripdir'))


def autoload_all(namespace)
  namespace.constants.each do |c|
    const = namespace.module_eval c
    autoload_all(const) if const.is_a? Module
  end
end

autoload_all Rip

require File.expand_path(File.join(File.dirname(__FILE__), 'mock_git'))

require 'fakefs'
require 'test/unit'
require 'test/spec/mini'

def repo_path(repo_name)
  RealFile.expand_path(RealFile.dirname(__FILE__) + '/repos/' + repo_name)
end

begin
  require 'redgreen'
rescue LoadError
end

class Test::Unit::TestCase
  def self.setup_with_fs(&block)
    define_method :setup do
      FakeFS::FileSystem.clear
      Rip::Env.create('other')
      Rip::Setup.setup_ripenv(Rip.dir)
      Rip::Env.create('base')
      setup_block
    end

    define_method(:setup_block, &block)
  end

  def fresh_remote_git(repo_name)
    Rip::GitPackage.mock_remote_git(repo_name)
  end

  def fresh_local_git(repo_name)
    Rip::GitPackage.mock_local_git(repo_name)
  end

end

module Rip
  class GitPackage
    # Since we don't have any mocking code, we monkey patch.
   
    def self.mock_remote_git(repo_name)
      real_source = "git://localhost/#{repo_name}"
      include_mock_git(repo_name, real_source)
    end

    def self.mock_local_git(repo_name)
      FakeFS::FileSystem.clone(repo_path(repo_name))
      FileUtils.mv(repo_path(repo_name)+'/dot_git', repo_path(repo_name)+'/.git')
      real_source = "file://#{repo_path(repo_name)}"
      include_mock_git(repo_name, real_source)
    end

    def self.include_mock_git(repo_name, real_source)
      Sh::MockGit.module_eval("def real_repo_name; #{repo_name.inspect}; end")
      Sh::MockGit.module_eval("def real_source; #{real_source.inspect}; end")

      include Sh::MockGit
      real_source
    end
    
    def self.unmock_git
      include Sh::Git
    end
  end
end
