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

desc "Run testing."
task :test do
  Dir['test/*_test.rb'].each do |file|
    puts "run '#{file}'..."
    puts `bundle exec ruby #{file}`
  end
end
