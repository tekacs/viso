require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.libs    << 'spec'
  t.pattern = 'spec/**/*_spec.rb'
  t.verbose = true
end

task :default => :test

desc 'Move documentation to the docs project root'
task :move_docs do
  sh 'mv docs/viso.html ../viso-docs/index.html && mv docs/* ../viso-docs'
end
