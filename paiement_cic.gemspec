# encoding: utf-8
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "paiement_cic"
  s.version     = "0.3"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Novelys Team", 'Guillaume Barillot']
  s.homepage    = "https://github.com/novelys/paiementcic"
  s.summary     = %q{CIC / Credit Mutuel credit card payment toolbox}
  s.description = %q{Paiement CIC is a gem to ease credit card payment with the CIC / Credit Mutuel banks system. It's a Ruby on Rails port of the connexion kits published by the bank.}

  s.files         = `git ls-files`.split("\n")
  s.require_paths = ["lib"]
end
