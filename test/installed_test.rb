require 'test/helper'

class InstalledTest < Rip::Test
  test "install cijoe.deps" do
    out = rip "install #{fixture('cijoe.deps')}"
    assert_exited_successfully out

    out = rip "installed"
    packages = [
      "#{@ripdir}/.packages/choice-09df20d2c7f13478ec2f50aed01b57d2",
      "#{@ripdir}/.packages/cijoe-20053386165d0ace45a91cd03c9ea31f",
      "#{@ripdir}/.packages/rack-02fff3f5181a7212c956d02aa6059a4e",
      "#{@ripdir}/.packages/sinatra-3712e6dc36199a4033913b0c08f1b0ce",
      "#{@ripdir}/.packages/tinder-822af7a6b7df6bafdb3795983a46add1"
    ]

    assert_equal packages.join("\n"), out.chomp

    assert_equal "#{@ripdir}/.packages/rack-02fff3f5181a7212c956d02aa6059a4e", rip("installed rack").chomp
    assert_equal "#{@ripdir}/.packages/choice-09df20d2c7f13478ec2f50aed01b57d2", rip("installed choice").chomp
    assert_exited_with_error rip("installed blahz")
  end
end
