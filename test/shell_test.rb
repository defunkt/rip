$LOAD_PATH.unshift File.dirname(__FILE__)
require 'helper'

class ShellTest < Rip::Test
  test "shell prints env vars" do
    output = rip "shell"
    assert_includes "RIPDIR=", output
    assert_includes "RUBYLIB=", output
    assert_includes "PATH=", output
  end

  test "shell uses active env if RIPENV is unset" do
    output = rip "shell"
    assert_includes "active", output
  end

  test "shell uses RIPENV if set" do
    output = rip "shell" do
      ENV['RIPENV'] = 'base'
    end
    assert_includes "base", output
  end
end
