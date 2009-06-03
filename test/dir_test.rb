$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))
require 'test_helper'

# temporary monkey patching before we stop using abort to make this
# testable
module Rip
  class Installer
    def abort(msg)
      raise msg
    end
  end
end

context 'Installing from a directory' do
  setup_with_fs do
    @source = fresh_local_dir('simple_d-1.2.3').source
  end

  test "installs the lib files" do
    Rip::Commands.install({}, @source)

    libpath = Rip.dir + '/active/lib/simple_d.rb'
    assert File.exists?(libpath), 'simple_d.rb should be installed'
  end

  test "finds version from name suffix" do
    assert_equal '1.2.3', fresh_local_dir('simple_d-1.2.3').version
  end

  test "defaults to unversioned if not named properly" do
    assert_equal 'unversioned', fresh_local_dir('simple_d').version
  end
end
