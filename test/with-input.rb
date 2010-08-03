require 'ideone'
require 'bacon'

describe 'an ideone gem user' do
  it 'can submit Ruby code with stdin and receive stdout' do
    paste_id = Ideone.submit(
      :ruby,
      %{
        input = $stdin.read
        puts "input was: \#{input}"
      }
    )
    results = Ideone.run( paste_id, 'some input' )
    results.should.equal %{input was: some input\n}
  end
end
