# capistrano-node

Capistrano tasks for deploying Node projects.

## What does it do?

* Skips migrations
* Installs NPM packages on deploy
* Manages multiple node versions using package.json

## Usage

In your deploy.rb

```ruby

require 'capistrano/node'

set :multi_node, true # To use multiple node versions
set :node_dir, '/opt/nodejs/versions' # Node dirs
set :version_prefix, 'v'
```

## Node Version Management

`capistrano-node` can manage multiple Node versions when `multi_node` variable
is set to `true`. In this case, it assumes that `node_dir` contains compiled
Node binaries for multiple versions each. For example, the directory could
contain files in following structure (assuming version prefix `'v'`):

    $NODE_DIR
      - v0.6.10
        - bin
          - node
          - node-waf
          - npm
          - npm_g
          - npm-g
      - v0.6.9
        - bin
          - node
          etc..

If multiple Node versions are used, `capistrano-node` reads used Node version
from `package.json`:

    "engines": {
      "node": ">= 0.6.14"
    }

We've also published our [Chef recipes for installing and distributing multiple Node versions](https://github.com/flowdock/nodejs-cookbook).

## Copyright

© [Flowdock](https://flowdock.com). See LICENSE.txt for further details.
