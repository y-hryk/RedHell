# -*- encoding: utf-8 -*-
# stub: grape 0.19.1 ruby lib

Gem::Specification.new do |s|
  s.name = "grape".freeze
  s.version = "0.19.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Michael Bleigh".freeze]
  s.date = "2017-01-09"
  s.description = "A Ruby framework for rapid API development with great conventions.".freeze
  s.email = ["michael@intridea.com".freeze]
  s.homepage = "https://github.com/ruby-grape/grape".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "2.6.8".freeze
  s.summary = "A simple Ruby framework for building REST-like APIs.".freeze

  s.installed_by_version = "2.6.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rack>.freeze, [">= 1.3.0"])
      s.add_runtime_dependency(%q<mustermann-grape>.freeze, ["~> 0.4.0"])
      s.add_runtime_dependency(%q<rack-accept>.freeze, [">= 0"])
      s.add_runtime_dependency(%q<activesupport>.freeze, [">= 0"])
      s.add_runtime_dependency(%q<multi_json>.freeze, [">= 1.3.2"])
      s.add_runtime_dependency(%q<multi_xml>.freeze, [">= 0.5.2"])
      s.add_runtime_dependency(%q<hashie>.freeze, [">= 2.1.0"])
      s.add_runtime_dependency(%q<virtus>.freeze, [">= 1.0.0"])
      s.add_runtime_dependency(%q<builder>.freeze, [">= 0"])
    else
      s.add_dependency(%q<rack>.freeze, [">= 1.3.0"])
      s.add_dependency(%q<mustermann-grape>.freeze, ["~> 0.4.0"])
      s.add_dependency(%q<rack-accept>.freeze, [">= 0"])
      s.add_dependency(%q<activesupport>.freeze, [">= 0"])
      s.add_dependency(%q<multi_json>.freeze, [">= 1.3.2"])
      s.add_dependency(%q<multi_xml>.freeze, [">= 0.5.2"])
      s.add_dependency(%q<hashie>.freeze, [">= 2.1.0"])
      s.add_dependency(%q<virtus>.freeze, [">= 1.0.0"])
      s.add_dependency(%q<builder>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<rack>.freeze, [">= 1.3.0"])
    s.add_dependency(%q<mustermann-grape>.freeze, ["~> 0.4.0"])
    s.add_dependency(%q<rack-accept>.freeze, [">= 0"])
    s.add_dependency(%q<activesupport>.freeze, [">= 0"])
    s.add_dependency(%q<multi_json>.freeze, [">= 1.3.2"])
    s.add_dependency(%q<multi_xml>.freeze, [">= 0.5.2"])
    s.add_dependency(%q<hashie>.freeze, [">= 2.1.0"])
    s.add_dependency(%q<virtus>.freeze, [">= 1.0.0"])
    s.add_dependency(%q<builder>.freeze, [">= 0"])
  end
end
