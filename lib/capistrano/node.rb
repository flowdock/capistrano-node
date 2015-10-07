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
  capture("ls #{path}").chomp.split("\n").map do |ver|
    Capistrano::Node.version ver, prefix
  end
end

Capistrano::Configuration.instance(:must_exist).load do |configuration|
  after :'deploy:finalize_update', :'deploy:symlink_node'
  after :'deploy:update_code', :'deploy:npm'

  set :multi_node, fetch(:multi_node, false)
  set :local, fetch(:local, false) # Local run?
  set :node_dir, fetch(:node_dir, '/opt/nodejs/versions') # Node versions dir
  set :version_prefix, fetch(:version_prefix, 'v') # Prefix for versin dirs, (v0.6.10 -> 'v')
  set :npm_flags, fetch(:npm_flags, '--production --quiet')
  set :force_node_version, fetch(:force_node_version, false)

  # Lazy variable to list available node versions from either local or remote
  set :available_node_versions do
    if local
      local_versions node_dir, version_prefix
    else
      remote_versions node_dir, version_prefix
    end.sort
  end

  # Export used Node version from package.json
  set :node_version do
    if force_node_version
      Capistrano::Node.exact_requirement 'package.json'
    else
      requirement = Capistrano::Node.requirement 'package.json'
      Capistrano::Node.choose_version requirement, available_node_versions
    end
  end

  set :node_version_dir do
    "#{node_dir}/#{version_prefix}#{node_version}/bin"
  end

  set :normalize_asset_timestamps, false # Don't touch public/images etc.

  namespace :node do
    desc 'List available node versions'
    task :versions do
      puts available_node_versions
    end

    desc 'Used Node version'
    task :used do
      if node_version
        puts node_version
      else
        puts red('No suitable node version found')
      end
    end
  end

  namespace :deploy do
    task :migrate do
      # Skip migrations
    end

    desc 'Symlink node version'
    task :symlink_node do
      next unless multi_node

      unless node_version
        puts red('No suitable node version found')
        exit
      end

      if local
        run_locally "mkdir bin;ln -snf #{node_version_dir}/* bin"
      else
        run "mkdir #{release_path}/bin; ln -snf #{node_version_dir}/* #{release_path}/bin"
      end
    end

    desc 'Build NPM packages'
    task :npm do
      run "export PATH=#{release_path}/bin:$PATH && cd #{release_path} && npm install #{npm_flags} && npm rebuild"
    end
  end
end
