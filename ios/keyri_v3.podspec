require 'yaml'

pubspec = YAML.load_file(File.join('..', 'pubspec.yaml'))

Pod::Spec.new do |spec|
  spec.name             = pubspec['name']
  spec.version          = pubspec['version']
  spec.summary          = 'Keyri Flutter plugin.'
  spec.description      = pubspec['description']
  spec.homepage         = pubspec['homepage']
  spec.license          = { :type => 'MIT License', :file => '../LICENSE' }
  spec.author           = 'kulagin.andrew38@gmail.com'
  spec.source           = { :path => '.' }

  spec.source_files = 'Classes/**/*'
  spec.public_header_files = 'Classes/**/*.h'

  spec.platform = :ios, '14.0'
  spec.dependency 'Flutter'
  spec.dependency 'keyri-pod', '~> 4.2.5'

  # Flutter.framework does not contain a i386 slice.
  spec.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  spec.swift_version = '5.0'
end
