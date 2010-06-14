require 'helper'

class PackageRipfileTest < Rip::Test
  test "can't urls" do
    out = rip "package-ripfile git://localhost/rails"
    assert_exited_with_error out
  end

  test "fetch all ripfile packages" do
    out = rip "package-ripfile #{fixture('cijoe-deps.rip')}"

    packages = [
      "#{@ripdir}/.packages/cijoe-98b937fa387d6b25fe3e114670d5ffc0"
    ]

    assert_equal packages.join("\n"), out.chomp, out
  end
end
