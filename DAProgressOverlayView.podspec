Pod::Spec.new do |s|
  s.name         = "DAProgressOverlayView"
  s.version      = "1.1"
  s.summary      = "A UIView subclass displaying download progress. Looks similarly to springboard icons of apps being downloaded in iOS 7. Layer-based version"
  s.homepage     = "https://github.com/Dreddik/DAProgressOverlayView.git"
  s.license      = 'MIT'
  s.author       = { "Daria Kopaliani" => "daria.kopaliani@gmail.com", "Roman Truba" => "dreddkr@gmail.com" }
  s.source       = { :git => "https://github.com/Dreddik/DAProgressOverlayView.git", :tag => "1.1" }
  s.platform     = :ios, '5.0'
  s.source_files = 'DAProgressOverlayView/*.{h,m}'
  s.requires_arc = true
end