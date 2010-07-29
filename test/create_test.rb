require 'helper'

class CreateTest < Rip::Test
  test "create ripenv" do
    assert_exited_successfully rip("create blah")
    assert File.exists?("#{@ripdir}/blah")
  end

  test "create existing ripenv" do
    assert_exited_successfully rip("create base")
    assert_equal "#{@ripdir}/base", File.readlink("#{@ripdir}/active")
    assert File.exists?("#{@ripdir}/base")
  end

  test "fails if RIPDIR is not set" do
    out = rip "create foo" do
      ENV.delete('RIPDIR')
    end
    assert_exited_with_error out
    assert_equal "$RIPDIR not set. Please eval `rip-shell`\n", out
  end

  test "invalid ripenv named 'active'" do
    out = rip "create active"
    assert_exited_with_error out
    assert_equal "Cannot name $RIPENV 'active'\n", out
  end

  test "creates .packages directory" do
    assert_exited_successfully rip("create blah")
    assert File.directory?("#{@ripdir}/.packages")
  end

  test "creates .cache directory" do
    assert_exited_successfully rip("create blah")
    assert File.directory?("#{@ripdir}/.cache")
  end
end
