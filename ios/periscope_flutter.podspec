Pod::Spec.new do |s|
  s.name             = 'periscope_flutter'
  s.version          = '0.1.0'
  s.summary          = 'Flutter bridge for PeriscopeKit.'
  s.description      = 'Flutter plugin that bridges PeriscopeKit on iOS.'
  s.homepage         = 'https://github.com/ryanneilstroud/periscope-flutter'
  s.license          = { :type => 'MIT' }
  s.author           = { 'ryanneilstroud' => 'ryanneilstroud@users.noreply.github.com' }
  s.source           = { :git => 'https://github.com/ryanneilstroud/periscope-flutter.git', :tag => s.version.to_s }
  s.source_files     = 'Classes/**/*'
  s.platform         = :ios, '15.0'
  s.swift_version    = '5.10'
  s.requires_arc     = true
  s.static_framework = true

  s.dependency 'Flutter'
  s.dependency 'PeriscopeKit', '0.5.0'
end
