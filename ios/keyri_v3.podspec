require 'yaml'

pubspec = YAML.load_file(File.join('..', 'pubspec.yaml'))
library_version = pubspec['version'].gsub('+', '-')

Pod::Spec.new do |s|
  s.name             = pubspec['name']
  s.version          = library_version
  s.summary          = 'Keyri Flutter plugin.'
  s.description      = pubspec['description']
  s.homepage         = pubspec['homepage']
  s.license          = { :type => 'MIT License', :file => '../LICENSE' }
  s.author           = 'kulagin.andrew38@gmail.com'
  s.source           = { :path => '.' }

  s.source_files = 'Classes/**/*'

  s.ios.deployment_target = '14.0'
  s.dependency 'Flutter'

  s.dependency 'keyri-pod'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
