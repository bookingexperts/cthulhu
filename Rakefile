require "bundler/gem_tasks"
require "rake/testtask"
require 'schema_dev/tasks'

# without this, we'll get a warning because DATABASES is already defined by
# schema_dev.
Object.send :remove_const, :DATABASES
DATABASES = %w[cthulhu_test]

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList['test/**/*_test.rb']
end

task :default => :spec
