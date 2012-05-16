$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "misfit/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "misfit"
  s.version     = Misfit::VERSION
  s.authors     = ["Ian White"]
  s.email       = ["ian.w.white@gmail.com"]
  s.homepage    = "http://github.com/i2w/misfit"
  s.summary     = "Flexible approach to handling exceptions in ruby (for library writers, or consumers)"
  s.description = "Flexible approach to handling exceptions in ruby (for library writers, or consumers).  Ispired by Avdi Grimm's excellent book 'Exceptional Ruby'."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md", "CHANGELOG"]
  s.test_files = Dir["spec/**/*"]
  
  s.add_dependency "activesupport", ">=3"
  s.add_development_dependency "rake"
  s.add_development_dependency "rspec", ">=2"
end
