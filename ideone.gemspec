spec = Gem::Specification.new do |s|
  s.name = 'ideone'
  s.version = '0.8.5'
  s.summary = 'A Ruby interface to the ideone.com API'

  s.author = 'Pistos'
  s.email = 'ideonegem dot pistos aet purepistos dot net'
  s.homepage = 'http://github.com/Pistos/ideone-gem'

  s.files = Dir[
    'lib/**/*.rb',
    'test/**/*.rb',
    'examples/**/*.rb',
    'LICENCE',
    'LICENSE',
    'README.md',
  ]
  s.add_development_dependency 'bacon'
end
