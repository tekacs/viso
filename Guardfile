guard 'bundler' do
  watch('Gemfile')
end

guard 'minitest', :load_path => 'lib' do
  watch(%r{^spec/(.*)_spec\.rb})
  watch(%r{^spec/helper\.rb})      { 'spec' }
  watch(%r{^lib/(.*)\.rb})         { |m| "spec/#{m[1]}_spec.rb" }
  watch(%r{^app/helpers/(.*)\.rb}) { |m| "spec/helpers/#{m[1]}_spec.rb" }
end
