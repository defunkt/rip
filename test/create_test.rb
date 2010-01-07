$LOAD_PATH.unshift File.dirname(__FILE__)
require 'helper'

class CreateTest < Rip::Test
  test "create ripenv" do
    rip "create blah"
    assert_exited_successfully
    assert_equal "#{@ripdir}/blah", File.readlink("#{@ripdir}/active")
    assert File.exists?("#{@ripdir}/blah")
  end

  test "create existing ripenv" do
    rip "create base"
    assert_exited_successfully
    assert_equal "#{@ripdir}/base", File.readlink("#{@ripdir}/active")
    assert File.exists?("#{@ripdir}/base")
  end

  test "fails if RIPDIR is not set" do
    out = rip "create foo" do
      ENV.delete('RIPDIR')
    end
    assert_exited_with_error
    assert_equal "$RIPDIR not set. Please eval `rip-shell`\n", out
  end

  test "invalid ripenv named 'active'" do
    out = rip "create active"
    assert_exited_with_error
    assert_equal "Cannot name $RIPENV 'active'\n", out
  end
end
