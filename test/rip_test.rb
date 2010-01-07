$LOAD_PATH.unshift File.dirname(__FILE__)
require 'helper'

class RipTest < Rip::Test
  test "no $RIPDIR set" do
    out = rip "env" do
      ENV.delete('RIPDIR')
    end
    assert_equal "$RIPDIR not set. Please eval `rip-shell`\n", out
  end

  test "invalid $RIPDIR" do
    out = rip "env" do
      ENV['RIPDIR'] = 'blah'
    end
    ripdir = File.expand_path('blah')
    assert_exited_with_error
    assert_equal "#{ripdir} not found. Please run `rip-setup`\n", out
  end

  test "use ripenv" do
    rip "create blah"
    rip "use base"
    assert_equal "#{@ripdir}/base", File.readlink("#{@ripdir}/active")
  end

  test "use fake ripenv" do
    out = rip "use not-real"
    assert_includes "Can't find", out
  end

  test "shell" do
    output = rip "shell"
    assert_includes "RIPDIR=", output
  end
end
