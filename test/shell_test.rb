$LOAD_PATH.unshift File.dirname(__FILE__)
require 'helper'

class ShellTest < Rip::Test
  test "shell" do
    output = rip "shell"
    assert_includes "RIPDIR=", output
  end
end
