$LOAD_PATH.unshift File.dirname(__FILE__)
require 'test/helper'

class ParseTest < Rip::Test
  test "basic" do
    out = rip("parse test/fixtures/basic.rip")
    assert_equal YAML.load(<<yaml), YAML.load(out)
---
- :version: 8fb7daf8
  :source: git://github.com/defunkt/resque
- :version: 0.4.1
  :source: git://github.com/rtomayko/ronn.git
- :source: bert
- :version: 1.0.0
  :source: ernie
- :source: mustache
yaml
  end

  test "complex" do
    out = rip("parse test/fixtures/complex.rip")
    assert_equal YAML.load(<<yaml), YAML.load(out)
---
- :source: git://github.com/ezmobius/redis-rb.git
  :name: redis
  :reported_version: "1.0"
- :source: git://github.com/brianmario/yajl-ruby.git
  :version: 0.6.3
- :dependencies:
  - :dependencies:
    - :dependencies:
      - :source: cgi_escape
      - :source: url_parser
        :version: 0.4.3
      :source: url_escape
    :source: rack
    :version: ">=1.0"
  - :dependencies:
    - :source: temple
    - :source: sass
      :version: 1.2.1
    :source: haml
    :version: 1.0.0
  :source: sinatra
  :version: 0.9.4
- :source: rake
- :source: git://github.com/quirkey/vegas.git
  :name: Vegas
  :version: v0.1.2
- :source: git://github.com/defunkt/resque
  :version: 8fb7daf8
- :source: git://github.com/rtomayko/ronn.git
  :version: 0.4.1
- :source: bert
- :source: ernie
  :version: 1.0.0
- :source: mustache
- :path: activerecord
  :source: git://github.com/rails/rails.git
yaml
  end
end
