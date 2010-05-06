require 'test/helper'

class MetaData < Rip::Test
  test "metadata" do
    package = rip "package-gem repl 0.1.0"
    assert_equal "repl 0.1.0\n", rip("metadata #{package}")
  end
end
