# Add files and commands to this file, like the example:
#   watch(%r{file/path}) { `command(s)` }
#
guard :shell do
  watch('src/grammar.y') {|m| `rake racc` }
  watch('src/lexer.rex') {|m| `rake rex` }
  watch(/test\/.*_test.rb/) {|m| `bundle exec ruby #{m[0]}` }
end
