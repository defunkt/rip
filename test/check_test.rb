$LOAD_PATH.unshift File.dirname(__FILE__)
require 'helper'

class CheckTest < Rip::Test
  def test_check
    rip "check"
    assert_exited_successfully
  end

  def test_no_ripdir
    out = rip "check" do
      ENV.delete('RIPDIR')
    end
    assert_exited_with_error
    assert_equal "$RIPDIR not set. Please eval `rip-shell`\n", out
  end

  def test_invalid_ripdir
    out = rip "check" do
      ENV['RIPDIR'] = 'blahblah'
    end
    assert_exited_with_error out

    ripdir = File.expand_path('blahblah')
    assert_equal "#{ripdir} not found. Please run `rip-setup`\n", out
  end

  def test_invalid_ripenv
    out = rip "check" do
      ENV['RIPENV'] = 'blahblah'
    end
    assert_exited_with_error out
    assert_equal "ripenv blahblah not found\n", out
  end

  def test_check_outputs_env_variables
    out = rip "check"
    assert_equal "RIPDIR=#{ENV['RIPDIR']}\nRIPENV=base\n", out
  end
end
