require 'test/helper'

class PackageRipfileTest < Rip::Test
  test "can't urls" do
    out = rip "package-ripfile git://localhost/rails"
    assert_exited_with_error out
  end

  test "fetch all ripfile packages" do
    out = rip "package-ripfile #{fixture('cijoe-deps.rip')}"

    packages = [
      "#{@ripdir}/.packages/choice-09df20d2c7f13478ec2f50aed01b57d2",
      "#{@ripdir}/.packages/cijoe-98b937fa387d6b25fe3e114670d5ffc0",
      "#{@ripdir}/.packages/rack-33646698262f264815d5d7245ff6b2e9",
      "#{@ripdir}/.packages/sinatra-3712e6dc36199a4033913b0c08f1b0ce",
      "#{@ripdir}/.packages/tinder-822af7a6b7df6bafdb3795983a46add1"
    ]

    assert_equal packages.join("\n"), out.chomp
  end
end
