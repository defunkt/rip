$LOAD_PATH.unshift File.dirname(__FILE__)
require 'helper'

class HandleTest < Rip::Test
  test "handle git:// as git" do
    out = rip "handle git://localhost/cijoe"
    assert_equal "git", out.chomp
  end

  test "handle file:// as git" do
    out = rip "handle file:///Users/chris/Projects/repl"
    assert_equal "git", out.chomp
  end

  test "handle .git as git" do
    out = rip "handle git@github.com:defunkt/rip.git"
    assert_equal "git", out.chomp
  end

  test "handle gem" do
    out = rip "handle rack"
    assert_equal "gem", out.chomp
  end

  test "can't handle unknown protocol" do
    out = rip "handle foo://bar"
    assert_exited_with_error
    assert_equal "no handler found for foo://bar", out.chomp
  end
end
