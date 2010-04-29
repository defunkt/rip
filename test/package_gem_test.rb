$LOAD_PATH.unshift File.dirname(__FILE__)
require 'helper'

class PackageGemTest < Rip::Test
  def setup
    start_gem_daemon
    super
  end

  test "can't handle unknown protocol" do
    out = rip "package-gem git://localhost/cijoe"
    assert_exited_with_error out
  end

  test "fetch gem with no version" do
    out = rip "package-gem repl"
    target = "#{@ripdir}/.packages/repl-21df4eaf07591b07688973bad525a215"

    assert_equal target, out.chomp
    assert File.directory?(target)
    assert File.file?("#{target}/bin/repl")
  end

  test "fetch gem with version" do
    out = rip "package-gem repl 0.1.0"
    target = "#{@ripdir}/.packages/repl-21df4eaf07591b07688973bad525a215"

    assert_equal target, out.chomp
    assert File.directory?(target)
    assert File.file?("#{target}/bin/repl")
  end

  test "fetch gem with unknown version" do
    out = rip "package-gem repl 3.0.0"
    assert_exited_with_error out

    assert_equal "repl 3.0.0 not found", out.chomp
  end

  test "fetch same gem twice" do
    out = rip "package-gem repl"
    assert_exited_successfully out

    out = rip "package-gem repl"
    assert_exited_successfully out
  end

  test "writes package.rip" do
    out = rip "package-gem repl"
    target = "#{@ripdir}/.packages/repl-21df4eaf07591b07688973bad525a215"

    assert_equal target, out.chomp
    assert File.exist?("#{target}/metadata.rip")
    assert_equal "repl 0.1.0\n",
      File.read("#{target}/metadata.rip")
  end

  test "writes deps.rip if it needs to" do
    out = rip "package-gem ambition"
    target = "#{@ripdir}/.packages/ambition-23537c5d0c31d3a0b0e3bcfa225a2dca"

    assert_equal target, out.chomp
    assert File.exist?("#{target}/deps.rip")
    assert_equal "ParseTree 2.1.1\nrubigen 1.1.1\nruby2ruby 1.1.8\n",
      File.read("#{target}/deps.rip")
  end

  test "doesn't write deps.rip if it doesn't need to" do
    out = rip "package-gem repl"
    target = "#{@ripdir}/.packages/repl-21df4eaf07591b07688973bad525a215"

    assert_equal target, out.chomp
    assert !File.exist?("#{target}/deps.rip")
  end
end
