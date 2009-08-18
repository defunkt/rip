Rip: Ruby's Intelligent Packaging
=================================

Rip is an attempt to create a next generation packaging 
system for Ruby.

For more thorough documentation please see the Rip site:

[http://hellorip.com/](http://hellorip.com/)

Introduction
------------

Let's get right to it then, shall we?

First we install rip.

    $ sudo gem install rip

Did that work? 

    $ rip check
    All systems go.

Yep. Let's see what libraries rip knows about.

    $ rip list
    ripenv: base
    
    nothing installed

None. Really? Let's try to require Grit.

    $ ruby -r grit -e 'puts Grit'
    ruby: no such file to load -- grit (LoadError)
    
Whoops. Not found. Let's install the latest using rip.

    $ rip install git://github.com/defunkt/grit.git v1.1.1b
    Successfully installed grit v1.1.1
    $ rip list
    ripenv: base

    diff-lcs (491fbc0)
    mime-types (v1.16)
    grit (v1.1.1)

Great, now we have Grit and all its dependencies.    

    $ ruby -r grit -e 'puts Grit'
    Grit
    $ ruby -r grit -e 'puts MIME::Types'
    MIME::Types

And we don't need any magical `require` statements to use them!

If we'd like, we can now move between rip environments to mix
and match libraries.    

    $ rip env create my_fresh_env
    ripenv: created my_fresh_env
    $ ruby -r grit -e 'puts Grit'
    ruby: no such file to load -- grit (LoadError)

And so much more.

Overview
--------

Inspired by Python's [virtualenv][1] and [pip][2], Rip aims to be a
simple and powerful way to install and manage Ruby packages.

### Multiple Package Support

Rip can install from a variety of sources: directories, single files,
git repositories - even Rubygems.

Adding a new package is [easy](/packages.html) and we expect Rip to
support more formats in the future.

### Virtual Environments

Virtual environments ("ripenvs") can be created so multiple versions of 
a package may be installed and used by different applications concurrently.

ripenvs are easy to create, copy, delete, and share. Recipes for creating
ripenvs are trivial to generate and publish.

### Install-time Dependency Resolution

Dependency checking happens when Rip packages are installed, not
when packages run.

A dependency graph is constructed for the entire virtual environment,
making it easy to debug leaf-node transitive dependency issues.

### Clear Error Messages

Installation and dependency errors should be clear and give as much
information as possible in order to help you fix the problem.

### Few Dependencies

Rip itself should work without anything but the Ruby standard 
library, for maximum portability.

Rip vs RubyGems
---------------

### No building

Rip's support for a variety of package types means there is nothing to
build and distribute.

Tag your Git repository and publicize the latest version, or just pass
around Gists. Rip does not care.

Rip dependencies are listed as separate lines in a plaintext file and
can reference any package type. As a result, Rip packages can depend
on existing Rubygems that aren't available from any other source.

This means projects unaware of Rip can be installed by Rip and managed by
ripenvs. Adding the dependencies yourself is easy.

### Multiple Environments

Rip makes it easy to have multiple environments with different
versions of libraries.

You could even clone a ripenv then upgrade a single library to test its impact
on the environment as a whole. Installation not go smoothly? Delete the new 
ripenev then continue using the stable one.

### Dependency Conflict Resolution

With Rip, version conflicts in dependencies are simpler to resolve: you
know exactly what version of which libraries are requesting which versions
of the same library at installation time. As a result conflicts are resolved
when you're thinking about installing your code, not later on when you're
thinking about running it.

### Hands off

Rip requires no changes to your code, only an optional `deps.rip` file added
to the root of your project. As a result you do not force Rip on anyone else
and individuals are free to re-package your code using other systems.

### Distributed

There is no canonical server for Rip packages, which may be good or bad.

Installing Packages
-------------------

Each Rip package optionally contains at the root a `deps.rip` file 
identifying it as a Rip package and listing its dependencies.

Let's take the [ambition][3] project as an example. This is its
`deps.rip` in full:

    git://github.com/drnic/rubigen.git REL-1.3.0
    git://github.com/seattlerb/ruby2ruby.git e3cf57559 # 1.1.8
    git://github.com/seattlerb/parsetree.git 480ede9d9 # 2.1.1

If you were to run `rip install git://github.com/defunkt/ambition` 
the following steps would occur:

* The source would be fetched and unpacked as `ambition` in the cwd
* The source of each dependency in `deps.rip` would be fetched
* Each dependency would be unpacked into the current ripenv at the revision or tag specified
* Each dependency's `deps.rip` would be fetched and unpacked into the ripenv, etc

As this process unfolds, a mapping of libraries and versions is kept 
in memory. When a library is declared multiple times at different 
versions the process is halted and the error reported.

If you've cloned `ambition` on your own you can still install the 
dependencies using `rip install deps.rip`

Uninstalling Packages
---------------------

The easiest way to mass uninstall packages is to delete your ripenv 
and create a new one. Otherwise, `rip uninstall package` will do the trick.

Rip will complain if you attempt to uninstall a package that others depend
on. To remove the package anyway, use `-y`. To remove the package and the
dependents, use `-d` (for dependents).

Extensions
----------

Rip will attempt to build extensions during installation through the 
`rip build` command.

You can also run `rip build PACKAGE` to try and build a package
manually.

Rip Directory Structure
-----------------------

Rip is currently user-specific.

Here is a typical directory structure for Rip:

    rip/
      - rip-packages/
      - active/
        - bin/
        - lib/  
      - base/
        - bin/
        - lib/
        - base.ripenv    
      - cheat/
        - bin/
        - lib/
        - cheat.ripenv     
      - thunderhorse/
        - bin/
        - lib/
        - thunderhorse.ripenv

The above contains three ripenvs: `base`, `cheat`, and `thunderhorse`. Each 
ripenv contains directories for executable binaries and Ruby source files.
They also include a generated `.ripenv` file containing metadata about
the ripenev and its packages.

This individual may use `base` for general tomfoolery (it's the
default), `cheat` for developing their Cheat application, and
`thunderhorse` for working on their new Thunderhorse project.

`active` is a symlink to the current, active ripenv. We also see a 
`rip-packages` directory. This is where Rip stores the raw repositories.

Let us focus on the `cheat` ripenv:

    rip/
      - cheat/
        - bin/
          - camping
        - lib/
          - markaby/
            - builder.rb
            - cssproxy.rb
            - metaid.rb
            - rails.rb
            - tags.rb
            - template.rb
          - markaby.rb
          - camping/
            - db.rb
            - fastcgi.rb
            - reloader.rb
            - session.rb
            - webrick.rb
          - camping-unabridged.rb
          - camping.rb
        - cheat.ripenv

When using the `cheat` ripenv, a `camping` binary will be in our `PATH`.

When running Ruby scripts, or even executing the `camping` binary, 
`rip/cheat/lib` will be in our $LOAD_PATH. Therefor we may, for instance, 
`require "markaby"` in a Ruby script and it will succeed.

In any other ripenv, the `cheat` ripenv's binaries and libraries are as
good as non-existant.

Hooks
-----

Rip environments may also contain a `rip-hooks` directory. Like this:

    rip/
      - cheat/
        - bin/
          - camping
        - lib/
         - markaby.rb
         - camping.rb
        - cheat.ripenv
        - rip-hooks/
          - after-use

Rip will attempt to execute various shell scripts inside the
`rip-hooks` directory during the course of use.

Hooks must exist and be executable in order to run. To see or edit
existing hooks, see `rip help hooks`.

Here is the complete list of current hooks:

* `before-leave` - Called in the current ripenv before switching to a 
   new ripenv. Passed the name of the current ripenv.
* `after-use` - Called in the current ripenv after switching to
   it. Passed the name of the new ripenv.

For a discussion and examples of `after-use` in action, see the
mailing list: http://is.gd/2meU6

Deployment
----------

Want to get a copy of your local environment on your deployment
server? Generate a `.rip` file with `rip freeze` then upload and
install it.

Shortcomings
------------

Currently it's UNIX-only. This is because Rip needs to manipulate the RUBYLIB 
and PATH environment variables so that Ruby knows where to find installed Rip
packages.

As a result, the setup script expects you to be running bash, zshell, or fish.

Contributors
------------

* [Chris Wanstrath](http://github.com/defunkt) (that's me!)
* [Jeff Hodges](http://github.com/jmhodges/)
* [Tom Preston-Werner](http://github.com/mojombo/)
* [John Barnette](http://github.com/jbarnette)
* [Blake Mizerany](http://github.com/bmizerany)
* [Ryan Tomayko](http://github.com/rtomayko)
* [Pat Nakajima](http://github.com/nakajima)
* [Eero Saynatkari](http://github.com/rue)
* [Coda Hale](http://github.com/codahale)
* [Simon Rozet](http://github.com/sr)
* [Gabriel Horner](http://github.com/cldwalker)
* [Pistos](http://github.com/Pistos)
* [Mark Turner](http://github.com/amerine)
* [Hongli Lai](http://github.com/FooBarWidget)
* [Tim Carey-Smith](http://github.com/halorgium)
* [August Lilleaas](http://github.com/augustl)
* [Andre Arko](http://github.com/indirect)
* [Rick Olson](http://github.com/technoweenie)
* [Ben Burkert](http://github.com/benburkert)
* [James Adam](http://github.com/lazyatom)

Special Thanks
--------------

* Coda Hale for the phrase "leaf-node transitive dependency issues"
* GitHub for sponsoring development

[1]: http://pypi.python.org/pypi/virtualenv
[2]: http://pypi.python.org/pypi/pip
[3]: http://github.com/defunkt/ambition
