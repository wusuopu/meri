desc "Generating parser using racc."
task :racc do
  `racc -o src/parser.rb src/grammar.y`
end

desc "Run testing."
task :test do
  Dir['test/*_test.rb'].each do |file|
    puts "run '#{file}'..."
    puts `bundle exec ruby #{file}`
  end
end
