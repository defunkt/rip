$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))
require 'test_helper'

context 'Installing from a RipfilePackage' do
  setup_with_fs do
    @package = fresh_ripfile('simple.rip')
    @source  = @package.source
  end

  test "installs the lib files" do
    Rip::Commands.install({}, @source)

    filelibpath = Rip.dir + '/active/lib/simple-file-3.2.1.rb'
    assert File.exists?(filelibpath), 'FilePackage should be installed'

    dirlibpath = Rip.dir + '/active/lib/simple_c.rb'
    assert File.exists?(dirlibpath), 'DirPackage should be installed'
  end
end
