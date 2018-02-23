# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

Gem::Specification.new do |s|
  s.name        = 'sdr-replication'
  s.version     = '1.0.0'
  s.licenses    = 'Apache-2.0'
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Darren Weber', 'Richard Anderson']
  s.summary     = 'Utilities for replication of objects to tape, DPN or other targets.'
  s.description = 'Contains classes to archive and retrieve digital object version content and metadata'
  s.homepage    = 'https://github.com/sul-dlss/sdr-replication'

  s.required_rubygems_version = '>= 2.2.1'

  # Runtime dependencies
  s.add_dependency 'rest-client'
  s.add_dependency 'moab-versioning'
  s.add_dependency 'archive-utils'

  s.add_development_dependency 'pry'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'awesome_print'
  s.add_development_dependency 'equivalent-xml'
  s.add_development_dependency 'fakeweb'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'coveralls'

  s.files        = Dir.glob('lib/**/*')
  s.require_path = 'lib'
end
