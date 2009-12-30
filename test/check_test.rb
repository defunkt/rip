$LOAD_PATH.unshift File.dirname(__FILE__)
require 'helper'

class CheckTest < Rip::Test
  def test_check
    rip "check"
    assert_exited_successfully
  end

  def test_failed_check
    rip "check" do
      ENV.delete('RIPDIR')
    end
    assert_exited_with_error
  end

  def test_check_outputs_env_variables
    out = rip "check"
    assert_equal "RIPDIR=#{ENV['RIPDIR']}\nRIPENV=base\n", out
  end
end
