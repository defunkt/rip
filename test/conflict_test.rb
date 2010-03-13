$LOAD_PATH.unshift File.dirname(__FILE__)
require 'helper'

class ConflictTest < Rip::Test
  test "detect-conflicts, none" do
    assert_exited_successfully rip("detect-conflicts test/fixtures/basic.rip")
  end

  test "detect-conflicts, one" do
    out = rip("detect-conflicts test/fixtures/bad.rip")
    assert_exited_with_error out
    assert_equal "ronn (0.4.1)\nronn (0.4.0)\n", out
  end

  test "detect-conflicts, file not found" do
    assert_exited_with_error rip("detect-conflicts test/fixtures/basic.zip")
  end
end
