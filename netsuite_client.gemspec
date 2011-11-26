# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{netsuite_client}
  s.version = "1.0"

  s.required_ruby_version = '~> 1.8.7'
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Vlad Jebelev"]
  s.date = %q{2011-11-25}
  s.description = %q{Ruby soap4r-based Netsuite client.}
  s.email = ["vlad@jebelev.com"]
  s.rdoc_options += ['-m', 'README.rdoc', '-x', 'lib/netsuite_client/soap*.*', 'lib/netsuite_client/netsuite*', 'lib/netsuite_client/string.rb', 'lib/netsuite_client/client.rb', 'README.rdoc']
  s.extra_rdoc_files = ["CHANGELOG", "Manifest.txt"]
  s.files = ["CHANGELOG", "Manifest.txt", "README.rdoc", "Rakefile", "TODO", "netsuite_client.gemspec"] + Dir['lib/**/*.rb'] + Dir['test/*.rb']
  s.homepage = %q{http://rubygems.org/gems/netsuite_client}
#  s.post_install_message = %q{PostInstall.txt}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{netsuiteclient}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Ruby soap4r-based Netsuite client.}
  s.test_files = ["test/netsuite_client_test.rb", "test/test_helper.rb"]

  s.add_dependency 'soap4r'
end
