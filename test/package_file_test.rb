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
    out = rip "package-file #{File.dirname(__FILE__)}/../bin/rip"
    target = "#{@ripdir}/.packages/rip-6acfb9c584250bad16d431f80c8b6f2d"

    assert_equal target, out.chomp
    assert File.exist?("#{target}/bin/rip")
  end

  test "writes package.rip" do
    out = rip "package-file #{File.dirname(__FILE__)}/../lib/escape.rb"
    target = "#{@ripdir}/.packages/escape-dcf57fea57cc7f44e0cbfb8fb0118e02"

    assert_equal target, out.chomp
    assert File.exist?("#{target}/metadata.rip")
    assert_equal "escape\n", File.read("#{target}/metadata.rip")
  end
end
