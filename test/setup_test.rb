require 'test/helper'

class SetupTest < Rip::Test
  test "setup creates base env" do
    assert File.exists?("#{@ripdir}/active")
    assert File.symlink?("#{@ripdir}/active")
    assert_equal "#{@ripdir}/base", File.readlink("#{@ripdir}/active")
    assert File.exists?("#{@ripdir}/base")
  end
end
