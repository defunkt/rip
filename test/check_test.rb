$LOAD_PATH.unshift File.dirname(__FILE__)
require 'helper'

class CheckTest < Rip::Test
  test "check" do
    rip "check"
    assert_exited_successfully
  end

  test "no ripdir" do
    out = rip "check" do
      ENV.delete('RIPDIR')
    end
    assert_exited_with_error
    assert_equal "$RIPDIR not set. Please eval `rip-shell`\n", out
  end

  test "invalid ripdir" do
    out = rip "check" do
      ENV['RIPDIR'] = 'blahblah'
    end
    assert_exited_with_error out

    ripdir = File.expand_path('blahblah')
    assert_equal "#{ripdir} not found. Please run `rip-setup`\n", out
  end

  test "invalid ripenv" do
    out = rip "check" do
      ENV['RIPENV'] = 'blahblah'
    end
    assert_exited_with_error out
    assert_equal "ripenv blahblah not found\n", out
  end

  test "check outputs env variables" do
    out = rip "check"
    assert_equal "RIPDIR=#{ENV['RIPDIR']}\nRIPENV=base\n", out
  end
end
