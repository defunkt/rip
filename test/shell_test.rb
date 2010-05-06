require 'test/helper'

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

  test "shell strips out old lib and path when changing envs" do
    output = rip "shell" do
      ENV['RIPENV'] = 'old'
      ENV['RUBYLIB'] = "#{ENV['RUBYLIB']}:#{ENV['RIPDIR']}/old/lib"
      ENV['PATH'] = "#{ENV['PATH']}:#{ENV['RIPDIR']}/old/bin"

      ENV['RIPENV'] = 'base'
    end

    assert_includes '$RIPDIR\/old\/bin', output
    assert_includes '$RIPDIR\/old\/lib', output
    assert_includes 'base', output
  end
end
