# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |gem|
  gem.name              = "ruby-vcard"
  gem.version           = "0.1.0"
  gem.authors           = ["Ribose, Inc."]
  gem.email             = ["info@ribose.com"]
  gem.homepage          = ""
  gem.summary           = "vCard support for ruby"
  gem.description       = <<'---'
This is a pure-ruby library for decoding and encoding vCard called ruby-vcard.
---

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency('rails', '>= 3.0.0')
  gem.add_dependency("rspec", ">= 2.0")
  gem.add_dependency('equivalent-xml')
  gem.add_dependency('nokogiri')
  gem.add_dependency('ruby-vobject')
end
