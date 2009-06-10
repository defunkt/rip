$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))
require 'test_helper'

context 'Installing from a remote git repo' do
  setup_with_fs do
    @source = fresh_remote_git('simple_c')
  end

  teardown do
    Rip::GitPackage.unmock_git
  end

  test "installs the lib files" do
    Rip::Commands.install({}, @source)

    libpath = Rip.dir + '/active/lib/simple_c.rb'
    assert File.exists?(libpath), 'simple_c.rb should be installed'
  end
end

context 'Installing from a local git repo' do
  setup_with_fs do
    @sources = fresh_local_git('simple_c')
  end

  teardown do
    Rip::GitPackage.unmock_git
  end
  
  test 'local installs the lib files' do
    Rip::Commands.install({}, @sources)
    libpath = Rip.dir + '/active/lib/simple_c.rb'
    assert File.exists?(libpath), 'simple_c.rb should be installed'
  end
end

