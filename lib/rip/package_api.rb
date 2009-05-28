#
# When writing your own package, you'll want to override the
# methods provided by PackageAPI.
#
# The following Package methods may also be of interested to
# you:
#
#   source     - The path, URL, or name of the package's source
#   cache_name - The name of the package's cache directory
#   cache_path - The path to the package's cache directory
#
# You'll also want your package to listen for certain patterns
# in sources.
#
# For example, a GitPackage is needed when the source begins with
# "git://". To hook this up, we'd add the following to
# Rip::GitPackage:
#
#   class Rip::GitPackage
#     handles "git://"
#   end
#
# The `handles` method can accept multiple parameters and
# regular expressions.
#
# It also accepts a block, which will be passed the source.
# If the block evaluates to true then that package type is used.
#
# For example:
#
#   class Rip::LocalGitPackage
#     handles do |source|
#       File.exists? File.join(source, '.git')
#     end
#   end
#

module Rip
  module PackageAPI
    # The package's name
    def name
      source
    end

    # We weren't given a specific version, so figure
    # out what the latest version is and return it
    def version
      "0.0.1"
    end

    # Does this package's source exist?
    def exists?
      true
    end

    # Grab the package and stick it in our local cache,
    # if it's not already there.
    def fetch!
      puts "fetching #{name}..."
    end

    # Unpack the package we want into the cache.
    def unpack!
      puts "unpacking #{self}..."
    end

    #
    # The following are more obscure hooks, not usually needed
    # for authoring a package.
    #

    # Does this package simply install other packages?
    # Usually not.
    def meta_package?
      false
    end

    # Should this package be cached in rip-packages?
    # Usually so.
    def cached?
      true
    end

    # A list of installed files. Usually handled by Package
    def files!
      []
    end

    # Packages we depend on. Usually handled by Package.
    def dependencies!
      []
    end
  end
end
