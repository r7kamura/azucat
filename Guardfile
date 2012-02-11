guard 'rspec', :version => 2 do
  watch('spec/spec_helper.rb')  { "spec" }
  watch(%r|^spec/.+_spec\.rb$|)
  watch(%r|^lib/(.+)\.rb$|)     { |m| "spec/lib/#{m[1]}_spec.rb" }
end
