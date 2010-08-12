require 'helper'

class PackageMetadataTest < Rip::Test
  test "metadata" do
    package = rip "package-handle-gem repl 0.1.0"
    assert_equal "repl 0.1.0\n", rip("package-metadata #{package}")
  end
end
