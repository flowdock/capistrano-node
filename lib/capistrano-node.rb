require 'json'

module Capistrano
  module Node
    extend self
    # Internal: Parse node version from string
    #
    # string - version string
    # prefix - prefix used in node versions, e.g. 'v', (default: '')
    #
    # Returns Gem::Version object
    def version(string, prefix = '')
      Gem::Version.create(string[prefix.length..-1])
    end

    # Internal: Choose best matching version for given requirement
    #
    # requirement - Gem::Requirement object
    # versions - Array of Gem::Versions
    #
    # Returns latest matching version
    def choose_version(requirement, versions = [])
      versions.sort.reduce(nil) do |used, candidate|
        if requirement.satisfied_by? candidate
          candidate
        else
          used
        end
      end
    end

    # Internal: Parse requirement from package.json
    #
    # file - package.json file object
    #
    # Returns Gem::Requirement
    def requirement(file)
      json = JSON.parse(File.open('package.json', 'r:utf-8').read)
      Gem::Requirement.create(json['engines']['node'])
    end
  end
end
