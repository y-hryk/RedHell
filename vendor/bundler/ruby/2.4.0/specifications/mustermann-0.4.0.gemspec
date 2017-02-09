# -*- encoding: utf-8 -*-
# stub: mustermann 0.4.0 ruby lib

Gem::Specification.new do |s|
  s.name = "mustermann".freeze
  s.version = "0.4.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Konstantin Haase".freeze]
  s.date = "2014-11-25"
  s.description = "library implementing patterns that behave like regular expressions".freeze
  s.email = "konstantin.mailinglists@googlemail.com".freeze
  s.homepage = "https://github.com/rkh/mustermann".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.1.0".freeze)
  s.rubygems_version = "2.6.8".freeze
  s.summary = "use patterns like regular expressions".freeze

  s.installed_by_version = "2.6.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<tool>.freeze, ["~> 0.2"])
    else
      s.add_dependency(%q<tool>.freeze, ["~> 0.2"])
    end
  else
    s.add_dependency(%q<tool>.freeze, ["~> 0.2"])
  end
end
