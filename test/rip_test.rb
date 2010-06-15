require 'helper'

class RipTest < Rip::Test
  test "rip prints error message for invalid command" do
    old_path = ENV['PATH']
    ENV['PATH'] = "bin:#{ENV['PATH']}"
    expected = "'invalid' is not a rip command. See rip's commands with 'rip-commands'."
    assert_equal expected, `rip invalid 2>&1`.chomp
    assert_exited_with_error
    ENV['PATH'] = old_path
  end
end