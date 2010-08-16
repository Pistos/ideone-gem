require 'ideone'
require 'bacon'

describe 'an ideone gem user' do
  it 'can submit Ruby code and receive stdout' do
    paste_id = Ideone.submit( :ruby, %{puts "text on stdout"} )
    results = Ideone.run( paste_id, nil )
    results.should.equal %{text on stdout\n}
  end

  it 'can submit Perl code and receive stdout' do
    paste_id = Ideone.submit( :perl, %{print "text on stdout\\n"} )
    results = Ideone.run( paste_id, nil )
    results.should.equal %{text on stdout\n}
  end

  it 'can submit Python code and receive stdout' do
    paste_id = Ideone.submit( :python, %{print "text on stdout"} )
    results = Ideone.run( paste_id, nil )
    results.should.equal %{text on stdout\n}
  end

  it 'can submit PHP code and receive stdout' do
    paste_id = Ideone.submit( :php, %{<?php echo "text on stdout\\n"; ?>} )
    results = Ideone.run( paste_id, nil )
    results.should.equal %{text on stdout\n}
  end

  it 'can submit Lua code and receive stdout' do
    paste_id = Ideone.submit( :lua, %{print "text on stdout"} )
    results = Ideone.run( paste_id, nil )
    results.should.equal %{text on stdout\n}
  end

  it 'can submit Tcl code and receive stdout' do
    paste_id = Ideone.submit( :tcl, %{puts "text on stdout";} )
    results = Ideone.run( paste_id, nil )
    results.should.equal %{text on stdout\n}
  end

  it 'can submit Bash code and receive stdout' do
    paste_id = Ideone.submit( :bash, %{echo "text on stdout"} )
    results = Ideone.run( paste_id, nil )
    results.should.equal %{text on stdout\n}
  end

  it "can submit Ruby code that doesn't print anything to stdout" do
    paste_id = Ideone.submit( :ruby, %{1+1} )
    results = Ideone.run( paste_id, nil )
    results.should.be.nil
  end

  it 'can submit Ruby code and receive stdout that has characters that would get HTML escaped' do
    paste_id = Ideone.submit( :ruby, %{p '1 < 2'} )
    results = Ideone.run( paste_id, nil )
    results.should.equal %{"1 < 2"\n}
  end
end
