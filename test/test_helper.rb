$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')
$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))

require 'rip'
require 'rip/commands'

Rip.dir = File.expand_path(File.join(File.dirname(__FILE__), 'ripdir'))
Rip.ui = nil

require 'mock_git'
require 'test/unit'

%w( fakefs test/spec/mini ).each do |dep|
  begin
    require dep
  rescue LoadError => e
    warn "*** run 'rip install test/dev.rip' before testing ***"
    raise e
  end
end

begin; require 'redgreen'; rescue LoadError; end

# For super rudimentary mocking...
def fake(object, method_name, options={})
  method = object.method(method_name)
  metaclass = class << object; self end
  return_value = options[:with]

  metaclass.class_eval do
    define_method(method_name) { |*args| return_value }
  end

  begin
    yield
  ensure
    metaclass.class_eval do
      define_method(method_name, method)
    end
  end
end

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

      Rip::PackageManager.new('other').save
      Rip::PackageManager.new('base').save

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

  def fresh_local_dir(repo_name)
    FakeFS::FileSystem.clone(repo_path(repo_name))
    Rip::DirPackage.new(repo_path(repo_name))
  end

  def fresh_local_file(repo_name)
    FakeFS::FileSystem.clone(repo_path(repo_name))
    Rip::FilePackage.new(repo_path(repo_name))
  end

  def fresh_ripfile(repo_name)
    FakeFS::FileSystem.clone(repo_path(''))
    Rip::RipfilePackage.new(repo_path(repo_name))
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
