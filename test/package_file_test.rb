require 'helper'

class PackageFileTest < Rip::Test
  test "can't handle directories" do
    out = rip "package-file #{File.dirname(__FILE__)}"
    assert_exited_with_error out
  end

  test "copies rb file into package lib" do
    out = rip "package-file #{File.dirname(__FILE__)}/../lib/rip.rb"
    target = "#{@ripdir}/.packages/rip-bea6586626e24aadcd4ff2f58874ea4f"

    assert_equal target, out.chomp
    assert File.exist?("#{target}/lib/rip.rb")
  end

  test "copies file without extension into package bin" do
    out = rip "package-file #{File.dirname(__FILE__)}/fixtures/rip"
    target = "#{@ripdir}/.packages/rip-04cc647c0987189abb5aa6245faf1adf"

    assert_equal target, out.chomp
    assert File.exist?("#{target}/bin/rip")
  end

  test "writes package.rip" do
    out = rip "package-file #{File.dirname(__FILE__)}/fixtures/rip.rb"
    target = "#{@ripdir}/.packages/rip-75204bff1c9dc6548077fb10c39da31d"

    assert_equal target, out.chomp
    assert File.exist?("#{target}/metadata.rip")
    assert_equal "rip\n", File.read("#{target}/metadata.rip")
  end
end
