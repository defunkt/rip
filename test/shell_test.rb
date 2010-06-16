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

  test "shell --push given no env prints error" do
    output = rip "shell --push"
    assert_equal "I need a ripenv.", output.chomp
  end

  test "shell --push given an invalid env prints error" do
    output = rip "shell --push blah"
    assert_equal "Can't find ripenv `blah'", output.chomp
  end

  test "shell --push prints function" do
    rip "create extra"
    output = rip "shell --push extra"
    assert_equal <<-expected, output
export PATH="$PATH:$RIPDIR/extra/bin";
export RUBYLIB="$RUBYLIB:$RIPDIR/extra/lib";
    expected
  end

  test "shell --pop given no env prints error" do
    output = rip "shell --pop"
    assert_equal "I need a ripenv.", output.chomp
  end

  test "shell --pop given an invalid env prints error" do
    output = rip "shell --pop blah"
    assert_equal "Can't find ripenv `blah'", output.chomp
  end

  test "shell --pop prints function" do
    rip "create extra"
    output = rip "shell --pop extra" do
      # emulate rip-push extra
      ENV['RUBYLIB'] += ":#{ENV['RIPDIR']}/extra/lib"
      ENV['PATH'] += ":#{ENV['RIPDIR']}/extra/bin"
    end
    assert_doesnt_include "extra", output
  end
end