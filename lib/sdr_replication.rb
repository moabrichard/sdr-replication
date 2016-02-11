require 'rubygems'
require 'bundler/setup'
Bundler.setup
require 'archive-utils'
require 'moab/stanford'

# The classes used for SDR Replication workflows
module Replication
end

require 'replication/archive_catalog'
require 'replication/replica'
require 'replication/sdr_object'
require 'replication/sdr_object_version'
include Replication

