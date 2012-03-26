# capistrano-node

Capistrano tasks for deploying Node projects.

## What does it do?

* Skips migrations
* Installs NPM packages on deploy
* Manages multiple node versions

## Usage

In your deploy.rb

```ruby

require 'capistrano/node'

set :multi_node, true # To use multiple node versions
set :node_dir, '/opt/nodejs/versions' # Node dirs
set :version_prefix, 'v'
```

## Copyright

Copyright (c) 2012 Flowdock Ltd. See LICENSE.txt for
further details.
