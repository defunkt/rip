$LOAD_PATH.unshift File.dirname(__FILE__)
require 'helper'

class RipTest < Rip::Test
  test "use ripenv" do
    rip "create blah"
    rip "use base"
    assert_equal "#{@ripdir}/base", File.readlink("#{@ripdir}/active")
  end

  test "use fake ripenv" do
    out = rip "use not-real"
    assert_includes "Can't find", out
  end
end
