require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "geokit-cache"
    gem.summary = %Q{Geokit caching support }
    gem.description = %Q{Caching support in database for locations geocoded by andre/geokit-gem}
    gem.email = "pr0d1r2@ragnarson.com"
    gem.homepage = "http://github.com/Pr0d1r2/geokit-cache"
    gem.authors = ["Marcin Nowicki"]
    gem.add_development_dependency "rspec"
    gem.add_development_dependency "Pr0d1r2-active_record_connectionless"
    gem.add_development_dependency "Pr0d1r2-active_record_geocodable"
    gem.add_development_dependency "htmlentities"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :spec => :check_dependencies

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  if File.exist?('VERSION')
    version = File.read('VERSION')
  else
    version = ""
  end

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "geokit-cache #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
