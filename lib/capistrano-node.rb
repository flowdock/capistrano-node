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

    # Internal: Parse requirement from `file`
    #
    # file - package.json file object
    #
    # Returns Gem::Requirement
    def requirement(file)
      Gem::Requirement.create(raw_requirement(file))
    end

    def exact_requirement(file)
      requirement = raw_requirement(file)
      raise "No exact node version specified" unless Gem::Requirement.create(requirement).exact?
      requirement
    end

    def raw_requirement(file)
      json = JSON.parse(File.open(file, 'r:utf-8').read)
      json['engines']['node'].strip
    end
end
