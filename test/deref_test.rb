$LOAD_PATH.unshift File.dirname(__FILE__)
require 'helper'

class FetchTest < Rip::Test
  def setup
    start_git_daemon
    super
  end

  test "deference git:// static ref" do
    out = rip "deref git://localhost/cijoe e021fc44c09d09d38a33e49d4f92901704e55c1e"
    repo, ref = out.chomp.split(" ")
    assert_equal "#{@ripdir}/.cache/cijoe-da109be2f8636efacba2984c933c2048", repo
    assert_equal "e021fc44c09d09d38a33e49d4f92901704e55c1e", ref
  end

  test "deference git:// shorthand ref" do
    out = rip "deref git://localhost/cijoe e021fc4"
    repo, ref = out.chomp.split(" ")
    assert_equal "#{@ripdir}/.cache/cijoe-da109be2f8636efacba2984c933c2048", repo
    assert_equal "e021fc44c09d09d38a33e49d4f92901704e55c1e", ref
  end

  test "deference git:// floating ref" do
    out = rip "deref git://localhost/cijoe master"
    repo, ref = out.chomp.split(" ")
    assert_equal "#{@ripdir}/.cache/cijoe-da109be2f8636efacba2984c933c2048", repo
    assert_equal "e021fc44c09d09d38a33e49d4f92901704e55c1e", ref
  end

  test "deference rubygem version"

  test "deference rubygem version comparison"
end
