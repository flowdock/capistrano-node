require 'capistrano-node'
require 'term/ansicolor'
include Term::ANSIColor

def local_versions(path, prefix)
  Dir.entries(path).select do |n|
    n[0] != '.'
  end.map do |ver|
    Capistrano::Node.version ver, prefix
  end
end

def remote_versions(path, prefix)
  capture("ls #{path}").chomp.split("\n").map do |ver|
    Capistrano::Node.version ver, prefix
  end
end

Capistrano::Configuration.instance(:must_exist).load do |configuration|
  after :'deploy:finalize_update', :'deploy:symlink_node'
  after :'deploy:update_code', :'deploy:npm'

  set :multi_node, false unless defined? multi_node
  set :local, false unless defined? local
  set :node_dir, '/opt/nodejs/versions' unless defined? node_dir
  set :version_prefix, 'v' unless defined? version_prefix
  set :available_node_versions do
    if local
      local_versions node_dir, version_prefix
    else
      remote_versions node_dir, version_prefix
    end.sort
  end

  set :node_version do
    requirement = Capistrano::Node.requirement 'package.json'
    Capistrano::Node.choose_version requirement, available_node_versions
  end

  set :normalize_asset_timestamps, false

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
      return unless multi_node

      unless node_version
        puts red('No suitable node version found')
        exit
      end

      if local
        run_locally "ln -snf #{node_dir}/#{version_prefix}#{node_version}/bin bin"
      else
        run "ln -snf #{node_dir}/#{version_prefix}#{node_version}/bin #{release_path}/bin"
      end
    end

    desc 'Build NPM packages'
    task :npm do
      run "export PATH=#{release_path}/bin:$PATH && cd #{release_path} && npm install && npm rebuild"
    end
  end
end
