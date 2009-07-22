$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))
require 'test_helper'

context 'Installing from a remote git repo' do
  setup_with_fs do
    @source = fresh_remote_git('simple_c')
    @libpath = Rip.dir + '/active/lib/simple_c.rb'
    @addedrb = Rip.dir + '/active/lib/added.rb'
  end

  teardown do
    Rip::GitPackage.unmock_git
  end

  test "installs the lib files" do
    Rip::Commands.install({}, @source)
    assert File.exists?(@libpath), 'simple_c.rb should be installed'
  end

  test "fails on an unknown version" do
    Rip::Commands.install({}, @source, 'deadbeef')
    assert !File.exists?(@libpath), 'simple_c.rb should not be installed'
  end

  test "works with a real version" do
    Rip::Commands.install({}, @source, 'master')
    assert File.exists?(@addedrb), 'added.rb should be installed'
    assert File.exists?(@libpath), 'simple_c.rb should be installed'
  end

  test "works with an existing sha" do
    Rip::Commands.install({}, @source, '3f1d6da')
    assert !File.exists?(@addedrb), 'added.rb should not be installed'
    assert File.exists?(@libpath), 'simple_c.rb should be installed'
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

