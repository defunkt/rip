$LOAD_PATH.unshift File.dirname(__FILE__)
require 'helper'

class UnpackTest < Rip::Test
  def setup
    start_git_daemon
    start_gem_daemon
    super
  end

  test "build returns original path if the package has no extensions" do
    out = rip "unpack git://localhost/cijoe"
    assert_exited_successfully out
    path = out.chomp

    out = rip "build #{path}"
    assert_equal path, out.chomp
  end

  test "build extconf" do
    out = rip "unpack git://localhost/yajl-ruby"
    assert_exited_successfully out
    path = out.chomp

    out = rip "build #{path}"
    target = "#{@ripdir}/.packages/yajl-ruby-b026ddaf414856f1874df270a20d222e"
    assert_equal target, out.chomp

    assert File.exist?("#{target}/ext/Makefile")
    assert Dir["#{target}/ext/yajl_ext.*"].any?

    assert File.exist?("#{target}/lib/yajl.rb")
    assert Dir["#{target}/lib/yajl_ext.*"].any?
  end
end
