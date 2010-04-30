$LOAD_PATH.unshift File.dirname(__FILE__)
require 'helper'

class ListTest < Rip::Test
  FIXTURES = File.expand_path(File.dirname(__FILE__) + "/fixtures")

  def setup
    start_git_daemon
    super
    rip "install git://localhost/cijoe"
  end

  test "lists installed packages" do
    assert_equal <<installed, rip("list")
rack (1f145ca111)
choice (8b12556493)
tinder (29fb44ca9e)
sinatra (e0ee682740)
cijoe (e8a53aac25)
installed
  end

  test "is ripenv specific" do
    rip "env -c newguy"
    rip "install git://localhost/rack"
    assert_equal <<installed, rip("list")
rack (01532da684)
installed
  end
end
