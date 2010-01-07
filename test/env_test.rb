$LOAD_PATH.unshift File.dirname(__FILE__)
require 'helper'

class EnvTest < Rip::Test
  test "prints out current RIPENV" do
    out = rip "env"
    assert_equal "base\n", out
  end

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
end
