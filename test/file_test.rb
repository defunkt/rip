$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))
require 'test_helper'

context 'Installing from a FilePackage' do
  setup_with_fs do
    @package = fresh_local_file('simple-file-3.2.1.rb')
    @source  = @package.source
  end

  test "installs the lib files" do
    Rip::Commands.install({}, @source)

    libpath = Rip.dir + '/active/lib/simple-file-3.2.1.rb'
    assert File.exists?(libpath), 'simple-file-3.2.1.rb should be installed'
  end

  test "fetching into cache_path" do
    @package.fetch!
    assert File.exists?(File.join(@package.cache_path, @package.name)), 'should fetch package and put in local cache'
  end

  test "finds version from name suffix" do
    assert_equal '1.2', fresh_local_file('simple-file-1.2.rb').version
    assert_equal '1.2.3', fresh_local_file('simple-file-1.2.3.rb').version
    assert_equal '1.2.3.4', fresh_local_file('simple-file-1.2.3.4.rb').version
  end

  test "defaults to date if not named properly" do
    date = Date.today
    fake Date, :today, :with => date do
      assert_equal date.to_s, fresh_local_file('simple-file.rb').version
    end
  end
end
