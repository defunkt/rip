require 'helper'

class PackageFetchDependenciesTest < Rip::Test
  test "fetch dependencies from package path" do
    package = rip "package git://localhost/cijoe"

    out = rip("package-fetch-dependencies #{package.chomp}")
    packages = [
      "#{@ripdir}/.packages/tinder-822af7a6b7df6bafdb3795983a46add1",
      "#{@ripdir}/.packages/sinatra-3712e6dc36199a4033913b0c08f1b0ce",
      "#{@ripdir}/.packages/rack-33646698262f264815d5d7245ff6b2e9",
      "#{@ripdir}/.packages/choice-09df20d2c7f13478ec2f50aed01b57d2"
    ]

    assert_equal packages.join("\n"), out.chomp
  end
end
