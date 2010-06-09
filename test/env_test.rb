require 'test/helper'

class EnvTest < Rip::Test
  test "prints out current RIPENV" do
    out = rip "env"
    assert_equal "base\n", out
  end

  test "creates a RIPENV" do
    rip "env -c newthing"
    assert_equal "  base\n* newthing\n", rip("envs")
  end

  test "branches a RIPENV" do
    rip "install repl 0.1.0"
    rip "env -b base-with-repl"
    assert_equal "ripenv: base-with-repl\n\nrepl (0.1.0)\n", rip("list")
  end

  test "deletes a RIPENV" do
    rip "env -c newthing"
    assert_includes "newthing", rip("envs")

    rip "env base"
    rip "env -d newthing"
    assert_equal "* base\n", rip("envs")
  end

  test "lists RIPENVs" do
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
    assert_exited_with_error out
    assert_equal "#{ripdir} not found. Please run `rip-setup`\n", out
  end

  test "switch to ripenv" do
    rip "create blah"
    rip "env base"
    assert_equal "#{@ripdir}/base", File.readlink("#{@ripdir}/active")
    assert_includes "* base", rip("envs")
  end

  test "switch to path ripenv" do
    rip "create blah"
    rip "env ./"
    assert_equal Dir.pwd, File.readlink("#{@ripdir}/active")
    assert_doesnt_include "*", rip("envs")
  end

  test "attempt to switch to fake ripenv" do
    out = rip "env not-real"
    assert_includes "Can't find", out
  end

  test "envs prints an indicator for pushed envs" do
    rip "env -c stacked"
    rip "env -c newthing"
    out = rip("envs") do
      # emulate `rip-push stacked`
      ENV['RUBYLIB'] += ":#{ENV['RIPDIR']}/stacked/lib"
    end
    assert_equal "  base\n* newthing\n+ stacked\n", out
  end
end
