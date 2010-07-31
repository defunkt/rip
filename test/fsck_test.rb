require 'helper'

class FsckTest < Rip::Test
  test "sanity check" do
    out = rip "fsck"
    assert_exited_successfully out
  end
end

