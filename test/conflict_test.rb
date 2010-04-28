$LOAD_PATH.unshift File.dirname(__FILE__)
require 'helper'

class ConflictTest < Rip::Test
  def setup
    start_gem_daemon
    super
  end

  test "detect-conflicts, none" do
    assert_exited_successfully rip("detect-conflicts test/fixtures/basic.rip")
  end

  test "detect-conflicts, one" do
    out = rip("detect-conflicts test/fixtures/bad.rip")
    assert_exited_with_error out
    assert_equal "ronn (0.4.0)\n", out
  end

  test "detect-conflicts, file not found" do
    assert_exited_with_error rip("detect-conflicts test/fixtures/basic.zip")
  end

  test "detect-conflicts, ignores matches in env" do
    rip "install repl 0.1.0"
    file = tempfile("repl 0.1.0\nblah 1.0")
    assert_exited_successfully rip("detect-conflicts #{file.path}")
  end

  test "detect-conflicts, ignores unversioned packages" do
    rip "install repl 0.1.0"
    file = tempfile("repl\nblah 1.0")
    assert_exited_successfully rip("detect-conflicts #{file.path}")
  end

  test "detect-conflics, one in env" do
    rip "install repl 0.1.0"

    file = tempfile(File.read("test/fixtures/basic.rip") + "\nrepl 0.1.1")

    out = rip("detect-conflicts #{file.path}")
    assert_exited_with_error out
    assert_equal "repl (0.1.1)\n", out

    rip "remove repl"
    assert_exited_successfully rip("detect-conflicts test/fixtures/basic.rip")
  end
end
