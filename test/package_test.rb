$LOAD_PATH.unshift File.dirname(__FILE__)
require 'helper'

class PackageTest < Rip::Test
  def setup
    start_git_daemon
    start_gem_daemon
    super
  end

  test "writes package.rip" do
    out = rip "package git://localhost/cijoe"
    target = "#{@ripdir}/.packages/cijoe-df5953e0bdf7d0c218632bb5d08cb458"

    assert File.exist?("#{target}/cijoe.rip")
    assert_equal "git://localhost/cijoe master\n",
      File.read("#{target}/cijoe.rip")
  end
end
