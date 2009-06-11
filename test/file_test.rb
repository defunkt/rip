$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))
require 'test_helper'

context 'Installing from a FilePackage' do
  setup_with_fs do
    @source = fresh_local_file('simple-file-3.2.1.rb').source
  end

  test "installs the lib files" do
    Rip::Commands.install({}, @source)

    libpath = Rip.dir + '/active/lib/simple-file-3.2.1.rb'
    assert File.exists?(libpath), 'simple-file-3.2.1.rb should be installed'
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
