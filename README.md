rip
===

Like [virtualenv][ve] + [pip][pp] for Ruby.

Installs and manages RubyGems, git repositories, and more.

We're currently in a developer-mode rewrite: rip2.


Installation
------------

The best way to install it right now is to clone with git then add to
your `$PATH`.

Got [hub][hb]?

    git clone defunkt/rip

Old school style:

    git clone git://github.com/defunkt/rip.git

Now set it up in your `~./bashrc` (or whatever):

    export RUBYLIB="$RUBYLIB:$HOME/Projects/rip/lib"
    export PATH="$PATH:$HOME/Projects/rip/bin"
    eval `rip-config`

Replace `$HOME/Projects/rip` with the path to your clone of rip. To
see what the `eval` statement is executing each time your shell opens,
run `rip-config` by hand:

    $ rip-config
    function rip-push() {
      eval `rip-sh-push $1`;
    };
    function rip-pop() {
      eval `rip-sh-pop $1`;
    };
    function rip-use {
      export RIPENV=$1;
      eval `rip-config`;
    };
    RIPVERBOSE=1
    RIPDIR=${RIPDIR:-"$HOME/.rip"}
    RUBYLIB="$RIPDIR/active/lib:$RUBYLIB"
    PATH="$RIPDIR/active/bin:$PATH"
    MANPATH="$RIPDIR/active/man:$MANPATH"
    export RIPVERBOSE RIPDIR RUBYLIB PATH MANPATH

That's what I get. So, let's test this thing out by seeing what envs
we have.

Let's try it:

    $ rip-envs
    $RIPDIR not set. Please eval `rip-shell`

Whoops. We need to restart our shell so the `~/.bashrc` changes take
hold. We can also run that `eval` command by hand, but it's easier
just to open a new shell.

Now, in our new shell:

    $ rip-envs
    /Users/chris/.rip not found. Please run `rip-setup`

Okay.

    $ rip-setup
    $ rip-envs
    * base

We're ready to roll.


Disabling rip
-------------

Many people installed Rip, played with it, realized it wasn't done,
then forgot about it - only to become frustrated when some package
they installed with Rip screwed up their development
environment. Those were the kinds of problems Rip was supposed to
solve! What does rip2 have to say about this?

Two words: `rip-off`. rip2 can be enabled or disabled at any time
using the `rip-off` and `rip-on` commands:

    $ rip-env
    choices
    $ ruby -r choice -e ''
    $ rip-off
    $ rip-env
    rip is currently disabled. `rip-on` to re-enable.
    $ ruby -r choice -e ''
    ruby: no such file to load -- choice (LoadError)
    $ rip-on
    $ ruby -r choice -e ''
    $ rip-env
    choices


Try It
------

    $ rip-env -c emailing
    $ rip-install mail
    fetching mail 2.2.0
    installed activesupport (2.3.5)
    installed mime-types (1.16)
    installed json_pure (1.4.2)
    installed rubyforge (2.0.4)
    installed minitest (1.6.0)
    installed rake (0.8.7)
    installed hoe (2.6.0)
    installed polyglot (0.3.1)
    installed treetop (1.4.5)
    installed mail (2.2.0)

It only fetched the packages I hadn't already installed in another
environment. Thanks, rip.

Now we can use our new library:

    $ irb -r mail
    >> Mail
    => Mail

When we move to another ripenv, we're in a new world:

    $ rip-env base
    base
    $ irb -r mail
    `require': no such file to load -- mail (LoadError)
      from /ruby/ree-1.8.7/lib/ruby/1.8/irb/init.rb:254:in `load_modules'


Dependencies
------------

When installing a RubyGem, rip respects dependencies. Installing from
a git repository? rip will check for a deps.rip and use that.

By default, rip assumes you don't want to overwrite installed
packages:

    $ rip-install rack 1.0.0
    installed rack (1.0.0)
    $ rip-install rack 1.1.0
    Conflicts
      rack
        1.1.0 requested, 1.0.0 already installed

Use `-f` to force the install:

    $ rip-install -f rack 1.1.0
    installed rack (1.1.0)

(This operation may need some polish, but it works.)


Common Commands
---------------

Installation:

    $ rip-install RUBYGEM
    $ rip-install RUBYGEM VERSION
    $ rip-install GIT_REPO
    $ rip-install GIT_REPO TAG_OR_VERSION
    $ rip-remove PACKAGE_NAME

Introspection:

    $ rip-list
    $ rip-config
    $ rip-installed
    $ rip-installed package

Environments:

    $ rip-envs
    $ rip-env -c NEW_RIPENV
    $ rip-env -d RIPENV_TO_DELETE
    $ rip-env RIPENV_TO_SWITCH_TO

Spring cleaning:

    $ rip-gc
    $ rip-fsck


Power Usage
-----------

I'm now using rip for all my development. This includes GitHub. Here
are fun things to do with rip today;

* [rip-readme](http://gist.github.com/390432)
* [Gemfile => deps.rip](http://gist.github.com/384613)
* [josh/rip-bundle](http://github.com/josh/rip-bundle)
* [josh/rip-externals](http://github.com/josh/rip-externals)
* [stacking ripenvs](http://gist.github.com/389001)


Compatibility
-------------

rip strives to be compatible with:

* POSIX
* bash 3
* Ruby 1.8.7
* Ruby 1.9.1
* RubyGems 1.3.7
* rpg 0.2.0
* git 1.7.0
* the Ruby Packaging Standard: <http://chneukirchen.github.com/rps/>


Running the Tests
-----------------

To run the test suite:

    $ rake


Contributing
------------

Once you've made your great commits:

1. [Fork][0] rip
2. Create a topic branch - `git checkout -b my_branch`
3. Push to your branch - `git push origin my_branch`
4. Create an [Issue][1] with a link to your branch
5. That's it!


Mailing List
------------

To join the list simply send an email to <rip@librelist.com>. This
will subscribe you and send you information about your subscription,
including unsubscribe information.

The archive can be found at <http://librelist.com/browser/>.


[hb]: http://github.com/defunkt/hub#readme
[ve]: http://pypi.python.org/pypi/virtualenv
[pp]: http://pypi.python.org/pypi/pip
[0]: http://help.github.com/forking/
[1]: http://github.com/defunkt/rip/issues
