require 'ideone'

code = %{
  puts "Hello, World!"
}

paste_id = Ideone.submit( :ruby, code )
p Ideone.run( paste_id, nil )

