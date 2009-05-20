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
    def name
      # The package's name
      "unnamed"
    end

    def fetch
      # Grab the package and stick it in our local cache,
      # if it's not already there.
      puts "fetching #{name}..."
    end

    def unpack(version)
      # Unpack the specific version of the package we
      # want into the cache.
      puts "unpacking #{name}..."
    end

    def infer_version
      # We weren't given a specific version, so figure
      # out what the latest version is and return it
      "0.0.1"
    end
  end
end
