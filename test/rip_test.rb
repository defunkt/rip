$LOAD_PATH.unshift File.dirname(__FILE__)
require 'helper'

class RipTest < Rip::Test
  test "setup" do
    assert File.exists?("#{@ripdir}/active")
    assert File.symlink?("#{@ripdir}/active")
    assert_equal "#{@ripdir}/base", File.readlink("#{@ripdir}/active")
    assert File.exists?("#{@ripdir}/base")
  end

  test "create ripenv" do
    rip "create blah"
    assert_exited_successfully
    assert_equal "#{@ripdir}/blah", File.readlink("#{@ripdir}/active")
    assert File.exists?("#{@ripdir}/blah")
  end

  test "create existing ripenv" do
    rip "create base"
    assert_exited_successfully
    assert_equal "#{@ripdir}/base", File.readlink("#{@ripdir}/active")
    assert File.exists?("#{@ripdir}/base")
  end
  
  test "invalid ripenv named 'active'" do
    out = rip "create active"
    assert_exited_with_error
    assert_equal "Cannot name $RIPENV 'active'\n", out
  end

  test "no $RIPDIR set" do
    out = rip "env" do
      ENV.delete('RIPDIR')
    end
    assert_equal "$RIPDIR not set. Please eval `rip-shell`\n", out
  end

  test "invalid $RIPDIR" do
    out = rip "env" do
      ENV['RIPDIR'] = 'blah'
    end
    ripdir = File.expand_path('blah')
    assert_exited_with_error
    assert_equal "#{ripdir} not found. Please run `rip-setup`\n", out
  end

  test "use ripenv" do
    rip "create blah"
    rip "use base"
    assert_equal "#{@ripdir}/base", File.readlink("#{@ripdir}/active")
  end

  test "use fake ripenv" do
    out = rip "use not-real"
    assert_includes "Can't find", out
  end

  test "shell" do
    output = rip "shell"
    assert_includes "RIPDIR=", output
  end
end
