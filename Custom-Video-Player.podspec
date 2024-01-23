Pod::Spec.new do |s|
  s.name             = 'Custom-Video-Player'
  s.version          = '0.1.0'
  s.summary          = 'A video player with custom playback controls, the ability to select subtitles and video quality, stream live content, as well as handle errors.'


  s.homepage         = 'https://github.com/ajkmr7/Custom-Video-Player'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Ajay Kumar' => 'ajayyasodha@gmail.com' }
  s.source           = { :git => 'https://github.com/ajkmr7/Custom-Video-Player.git', :tag => s.version.to_s }

  s.ios.deployment_target = '11.0'

  s.source_files = 'Custom-Video-Player/Classes/**/*'
  s.dependency 'SnapKit'
  
   s.resource_bundles = {
    'Custom-Video-Player' => ['Custom-Video-Player/Assets/**']
  }
  s.resources = ['Custom-Video-Player/Assets/**']
end
