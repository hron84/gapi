require 'rubygems'
require 'bundler'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

if File.exists? File.expand_path('./.gapi-key', File.dirname(__FILE__))
  gapi = File.read File.expand_path('./.gapi-key', File.dirname(__FILE__))
  ENV['GAPI_KEY'] = gapi.strip
end

require 'rake'

require 'jeweler'

Jeweler::Tasks.new do |gem|
  gem.name = 'gapi'
  gem.summary = 'Google API wrapper for Search and Translate'
  gem.email = 'daniel@bovensiepen.net'
  gem.homepage = 'https://github.com/bovi/gapi'
  gem.authors = [
    'Daniel Bovensiepen',
    'Dingding Ye'
  ]
  gem.files = Dir.glob('lib/**/*.rb') + Dir.glob('tests/**/*.rb') + %w[VERSION README MIT-LICENSE ChangeLog Rakefile Gemfile]
  gem.add_dependency 'json_pure'
end

Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new do |t|
  t.libs << 'tests'
  t.test_files = FileList['tests/**/*.rb']
end

require 'rdoc/task'
Rake::RDocTask.new(:rdoc => "doc", :clobber_rdoc => "doc:clean",
               :rerdoc => "doc:rebuild") do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "Google API (GAPI) #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

task :default => :test
