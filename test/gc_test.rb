require 'helper'

class GcTest < Rip::Test
  test "sanity check" do
    out = rip "gc"
    assert_exited_successfully out
  end
end
