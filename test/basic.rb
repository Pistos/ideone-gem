require 'ideone'
require 'bacon'

describe 'ideone gem user' do
  it 'can submit Ruby code and receive stdout' do
    paste_id = Ideone.submit( :ruby, %{puts "text on stdout"} )
    results = Ideone.run( paste_id, nil )
    results.should.equal %{text on stdout\n}
  end
end
