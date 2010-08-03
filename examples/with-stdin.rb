require 'ideone'

code = %{
  input = $stdin.read
  puts "input was: \#{input}"
}

$stdout.print "Enter a little text: "
$stdout.flush

text = $stdin.gets.strip

paste_id = Ideone.submit( :ruby, code )
p Ideone.run( paste_id, text )
