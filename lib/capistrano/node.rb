require 'capistrano-node'
require 'term/ansicolor'
include Term::ANSIColor

# Available local Node versions
def local_versions(path, prefix)
  Dir.entries(path).select do |n|
    n[0] != '.'
  end.map do |ver|
    Capistrano::Node.version ver, prefix
  end
end

# Available remote Node versions
def remote_versions(path, prefix)
  on roles(:all) do
    capture("ls #{path}").chomp.split("\n").map do |ver|
      Capistrano::Node.version ver, prefix
    end
  end
end

load File.expand_path('../tasks/node.cap', __FILE__)
