$LOAD_PATH.unshift File.dirname(__FILE__)
require 'helper'

class InstallTest < Rip::Test
  test "copy-paths" do
    out = rip "fetch git://localhost/cijoe"
    copied = rip "copy-paths #{out}"

    files = %w(
      lib/cijoe/build.rb
      lib/cijoe/campfire.rb
      lib/cijoe/commit.rb
      lib/cijoe/config.rb
      lib/cijoe/public/favicon.ico
      lib/cijoe/public/octocat.png
      lib/cijoe/public/screen.css
      lib/cijoe/server.rb
      lib/cijoe/version.rb
      lib/cijoe/views/template.erb
      lib/cijoe.rb
    )

    assert_equal files.join("\n") + "\n", copied
  end

  test "detect-conflicts" do

  end
end
