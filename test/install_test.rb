$LOAD_PATH.unshift File.dirname(__FILE__)
require 'helper'

class InstallTest < Rip::Test
  test "detect-conflicts, none" do
    out = rip "fetch #{fixture(:cijoe)}"
    assert_exited_successfully rip("detect-conflicts #{out.chomp}/deps.rip")
  end

  test "detect-conflicts, one" do
    out = rip "fetch #{fixture(:cijoe)}"
    assert_exited_with_error rip("detect-conflicts #{out.chomp}/deps.rip")
  end

  test "detect-conflicts, file not found" do
    out = rip "fetch #{fixture(:cijoe)}"
    assert_exited_with_error rip("detect-conflicts #{out.chomp}/deps.zip")
  end
end
