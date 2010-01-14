$LOAD_PATH.unshift File.dirname(__FILE__)
require 'helper'

class FetchTest < Rip::Test
  def setup
    start_git_daemon
    super
  end

  test "fetch git://" do
    out = rip "fetch git://localhost/cijoe"
    target = "#{@ripdir}/.packages/cijoe-da109be2f8636efacba2984c933c2048"
    assert_equal target, out.chomp
    assert File.directory?(target)
  end

  test "fetch twice" do
    out = rip "fetch git://localhost/cijoe"
    target = "#{@ripdir}/.packages/cijoe-da109be2f8636efacba2984c933c2048"
    assert_equal target, out.chomp

    out = rip "fetch git://localhost/cijoe"
    target = "#{@ripdir}/.packages/cijoe-da109be2f8636efacba2984c933c2048"
    assert_equal target, out.chomp
  end

  test "fetch git@"

  test "fetch hg"

  test "fetch bzr"

  test "fetch http tar.gz"

  test "fetch http tar.bz"

  test "fetch svn"

  test "fetch dependencies" do
    out = rip "fetch git://localhost/cijoe"
    rip "fetch-dependencies #{out.chomp}/deps.rip"
    fetched = Dir["#{@ripdir}/.packages/*"].map do |f|
      File.basename(f).split('-', 2)[0]
    end
    assert_equal %w( cijoe rack sinatra tinder choice ).sort, fetched.sort
  end
end
