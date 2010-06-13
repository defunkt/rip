require 'helper'

class RecursiveLinkTest < Rip::Test
  def setup
    super

    @target = "#{@ripdir}/base/lib"
    mkdir_p @target

    @source = "#{@ripdir}/foo/lib"
    mkdir_p @source
  end

  test "missing source and target causes an error" do
    out = rip("recursive-link")
    assert_exited_with_error out
    assert_equal "missing source and target", out.chomp
  end

  test "missing target causes an error" do
    out = rip("recursive-link #{@source}")
    assert_exited_with_error out
    assert_equal "missing source and target", out.chomp
  end

  test "links top level files and dirs into target" do
    touch "#{@source}/foo.rb"
    mkdir "#{@source}/foo"
    touch "#{@source}/foo/version.rb"

    out = rip("recursive-link #{@source} #{@target}")
    assert_exited_successfully out

    assert File.symlink?("#{@target}/foo.rb")
    assert File.symlink?("#{@target}/foo")
  end

  test "clobbers previous file symlinks" do
    other_source = "#{@ripdir}/bar/lib"
    mkdir_p other_source
    touch "#{other_source}/foo.rb"

    out = rip("recursive-link #{other_source} #{@target}")
    assert_exited_successfully out

    assert File.symlink?("#{@target}/foo.rb")
    assert_equal "#{other_source}/foo.rb", File.readlink("#{@target}/foo.rb")

    touch "#{@source}/foo.rb"

    out = rip("recursive-link #{@source} #{@target}")
    assert_exited_successfully out

    assert File.symlink?("#{@target}/foo.rb")
    assert_equal "#{@source}/foo.rb", File.readlink("#{@target}/foo.rb")
  end

  test "links merges existing target directory with source" do
    mkdir "#{@target}/foo"
    touch "#{@target}/foo/bar.rb"

    mkdir "#{@source}/foo"
    touch "#{@source}/foo/baz.rb"

    out = rip("recursive-link #{@source} #{@target}")
    assert_exited_successfully out

    assert File.directory?("#{@target}/foo")
    assert File.file?("#{@target}/foo/bar.rb")
    assert File.symlink?("#{@target}/foo/baz.rb")
  end

  test "expand target symlink" do
    other_source = "#{@ripdir}/bar/lib"
    mkdir_p other_source

    mkdir "#{other_source}/foo"
    touch "#{other_source}/foo/bar.rb"

    out = rip("recursive-link #{other_source} #{@target}")
    assert_exited_successfully out

    mkdir "#{@source}/foo"
    touch "#{@source}/foo/baz.rb"

    out = rip("recursive-link #{@source} #{@target}")
    assert_exited_successfully out

    assert File.directory?("#{@target}/foo")
    assert File.symlink?("#{@target}/foo/bar.rb")
    assert File.symlink?("#{@target}/foo/baz.rb")
  end
end
