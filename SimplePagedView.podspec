Pod::Spec.new do |s|

  s.name         = "SimplePagedView"
  s.version      = "1.0.1"
  s.summary      = "A PageViewController replacement built to be as simple as possible"

  s.description  = <<-DESC
A PageViewController replacement built to be as simple as possible to use. Supports easy insertion of views and the classic page dots. Also supports many customization points alongside reasonable defaults.
                   DESC

  s.homepage     = "http://github.com/redbooth/SimplePagedView"

  s.license      = "MIT"

  s.author             = { "Alex Reilly" => "alexander.r.reilly@gmail.com" }
  s.social_media_url   = "https://twitter.com/TheWisestFools"

  s.platform     = :ios, "10.3"


  s.source       = { :git => "https://github.com/redbooth/SimplePagedView.git", :tag => s.version }

  s.source_files = "SimplePagedViewFramework/**/*{swift}"

  s.swift_version = "4.2"

end
