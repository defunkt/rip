$LOAD_PATH.unshift File.dirname(__FILE__)
require 'helper'

class DependencyTest < Rip::Test
  test "pretty tree" do
    assert_equal <<-tree, rip("dependency-tree test/fixtures/complex.rip")
test/fixtures/complex.rip
|-- git://github.com/ezmobius/redis-rb.git
|-- git://github.com/brianmario/yajl-ruby.git (0.6.3)
|-- sinatra (0.9.4)
|   |-- rack (1.0)
|   |   `-- url_escape
|   |       |-- cgi_escape
|   |       `-- url_parser (0.4.3)
|   `-- haml (1.0.0)
|       |-- temple
|       `-- sass (1.2.1)
|-- rake
|-- git://github.com/quirkey/vegas.git (v0.1.2)
|-- git://github.com/defunkt/resque (8fb7daf8)
|-- git://github.com/rtomayko/ronn.git (0.4.1)
|-- bert
|-- ernie (1.0.0)
|-- mustache
`-- git://github.com/rails/rails.git
tree
  end
end
