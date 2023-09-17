Pod::Spec.new do |s|
  s.name             = 'Custom-Video-Player'
  s.version          = '0.0.1'
  s.summary          = 'A custom video player with subtitle selection support for iOS as of now.'


  s.homepage         = 'https://github.com/ajkmr7/Custom-Video-Player'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Ajay Kumar' => 'ajayyasodha@gmail.com' }
  s.source           = { :git => 'https://github.com/ajkmr7/Custom-Video-Player.git', :tag => s.version.to_s }

  s.ios.deployment_target = '11.0'

  s.source_files = 'Custom-Video-Player/Classes/**/*'
  s.dependency 'SnapKit'
end
