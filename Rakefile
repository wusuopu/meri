desc "Generating parser using racc."
task :racc do
  `bundle exec racc -v -g -o src/parser.rb src/grammar.y`
end

desc "Generating lexer using rex."
task :rex do
  `bundle exec rex src/lexer.rex -o src/lexer.rb`
end

desc "Build program."
task :build => [:racc, :rex] do
end


require "rake/testtask"

Rake::TestTask.new do |t|
  t.test_files = FileList['test/*_test.rb']
  t.verbose = true
end
