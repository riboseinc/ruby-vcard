# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vcard/version'

Gem::Specification.new do |gem|
  gem.name              = "vobject-vcard"
  gem.version           = "0.2.0"
  gem.authors           = ["Ribose, Inc.", "Nick Nicholas"]
  gem.email             = ["info@ribose.com", "opoudjis@gmail.com"]
  gem.homepage          = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

end

Gem::Specification.new do |spec|
  spec.name          = "vobject-vcard"
  spec.version       = Vobject::VERSION
  spec.authors       = ["Ribose Inc."]
  spec.email         = ["open.source@ribose.com"]

  spec.summary       = %q{TODO: Write a short summary, because Rubygems requires one.}
  spec.description   = %q{TODO: Write a longer description or delete this line.}
  spec.summary       = %q{vCard support for Ruby using vObject parsing}
  spec.description   = %q{Pure Ruby library for decoding and encoding vCards using the vObject structure}

  spec.homepage      = "https://www.ribose.com"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # if spec.respond_to?(:metadata)
  #   spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  # else
  #   raise "RubyGems 2.0 or newer is required to protect against " \
  #     "public gem pushes."
  # end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'ruby-vobject'

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec-json_expectations"
  spec.add_development_dependency "rspec", "~> 3.6"
  spec.add_runtime_dependency "rsec"

end
