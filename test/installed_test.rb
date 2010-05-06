require 'test/helper'

class InstalledTest < Rip::Test
  test "install cijoe.deps" do
    out = rip "install #{fixture('cijoe.deps')}"
    assert_exited_successfully out

    out = rip "installed"
    packages = [
      "#{@ripdir}/.packages/choice-09df20d2c7f13478ec2f50aed01b57d2",
      "#{@ripdir}/.packages/cijoe-20053386165d0ace45a91cd03c9ea31f",
      "#{@ripdir}/.packages/rack-4c4eec386dda665c2a1e094d579bfd11",
      "#{@ripdir}/.packages/sinatra-5ee77d98533655e154c3f9cc884c4e5e",
      "#{@ripdir}/.packages/tinder-dd78808be07b3957c256ddaa4e76db4c"
    ]

    assert_equal packages.join("\n"), out.chomp

    assert_equal "#{@ripdir}/.packages/rack-4c4eec386dda665c2a1e094d579bfd11", rip("installed rack").chomp
    assert_equal "#{@ripdir}/.packages/choice-09df20d2c7f13478ec2f50aed01b57d2", rip("installed choice").chomp
    assert_exited_with_error rip("installed blahz")
  end
end
