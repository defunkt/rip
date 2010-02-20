$LOAD_PATH.unshift File.dirname(__FILE__)
require 'helper'

class FetchTest < Rip::Test
  def setup
    start_git_daemon
    super
  end

  test "deference git:// static ref" do
    out = rip "deref git://localhost/cijoe e021fc44c09d09d38a33e49d4f92901704e55c1e"
    assert_equal "e021fc44c09d09d38a33e49d4f92901704e55c1e", out.chomp
  end

  test "deference git:// shorthand ref" do
    out = rip "deref git://localhost/cijoe e021fc4"
    assert_equal "e021fc44c09d09d38a33e49d4f92901704e55c1e", out.chomp
  end

  test "deference git:// floating ref" do
    out = rip "deref git://localhost/cijoe master"
    assert_equal "e021fc44c09d09d38a33e49d4f92901704e55c1e", out.chomp
  end

  test "deference rubygem version" do
    out = rip "deref github"
    assert_equal "0.4.1", out.chomp
  end

  test "deference rubygem version comparison"
end
