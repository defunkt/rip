Rip: Ruby's Intelligent Packaging
=================================

Rip is an attempt to create an intelligent packaging system
for Ruby.

Overview
--------

Inspired by Python's [virtualenv][1] and [pip][2], Rip aims to be a
simple and powerful way to install and manage Ruby packages.

### SCM-Based Installation

All packages are installed from source. Versioning is done by locking
to a specific revision or tag in the package's source repository.

As a result, each package's source is explicit rather than implicit.

### Virtual Environments

Virtual environments ("ripenvs") can be created so multiple versions of 
a package may be installed and used by different applications concurrently.

ripenvs are easy to create, clone, delete, and share. Recipes for creating
ripenvs are trivial to generate and publish.

### Install-time Dependency Resolution

Dependency checking happens when Rip packages are installed, not
when packages run.

A dependency graph is constructed for the entire virtual environment,
making it easy to debug leaf-node transitive dependency issues.

### Clear Error Messages

Installation and dependency errors should be clear and follow these
guiding principles:

* Explain what was expected
* Explain what occurred
* Offer a solution suggestion

### Few Dependencies

Rip itself should work without anything but the Ruby standard 
library, for maximum portability.

Installing Packages
-------------------

Each Rip package contains at the root a `deps.txt` file identifying
it as a Rip package and listing its dependencies.

Let's take the [ambition][3] project as an example. This is its
`deps.txt` in full:

    git://github.com/drnic/rubigen.git REL-1.3.0
    git://github.com/seattlerb/ruby2ruby.git e3cf5755910e65546ddfc7cb33a696964060b4e7 # 1.1.8
    git://github.com/seattlerb/parsetree.git 480ede9d94168c16ac6ca6da36319ead5e352e6b # 2.1.1

If you were to run `rip install git://github.com/defunkt/ambition.git` 
the following steps would occur:

* The source would be fetched and unpacked as `ambition` in the cwd
* The source of each dependency in `deps.txt` would be fetched
* Each dependency would be unpacked into the current virutalenv at the revision or tag specified
* Each dependency's `deps.txt` would be fetched and unpacked into the virutalenv, etc

As this process unfolds, a mapping of libraries and versions is kept in memory. When a library is
declared multiple times at different versions the process is halted and the error reported.

If you've cloned `ambition` on your own you can still install the dependencies using `rip install deps.txt`

Uninstalling Packages
---------------------

The easiest way to uninstall packages is to delete your ripenv and create a new one.

[1]: http://pypi.python.org/pypi/virtualenv
[2]: http://pypi.python.org/pypi/pip
[3]: http://github.com/defunkt/ambition
