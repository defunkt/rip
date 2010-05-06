require 'test/helper'

class ListTest < Rip::Test
  def setup
    super
    rip "install git://localhost/cijoe"
  end

  test "lists installed packages" do
    assert_equal <<installed, rip("list")
ripenv: base

choice (8b12556493)
cijoe (e8a53aac25)
rack (1.0)
sinatra (0.9.4)
tinder (1.2.0)
installed
  end

  test "is ripenv specific" do
    rip "env -c newguy"
    rip "install git://localhost/rack"
    assert_equal <<installed, rip("list")
ripenv: newguy

rack (01532da684)
installed
  end
end
