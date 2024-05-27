Pod::Spec.new do |s|
  s.name             = "HDKitCore"
  s.version          = "1.4.14"
  s.summary          = "混沌 iOS 项目组件库公共依赖库"
  s.description      = <<-DESC
                       HDKitCore 是混沌 iOS 项目组件库公共依赖库
                       DESC
  s.homepage         = "https://code.kh-super.net/projects/MOB/repos/hdkitcore/"
  s.license          = 'MIT'
  s.author           = {"VanJay" => "wangwanjie1993@gmail.com"}
  s.source           = {:git => "ssh://git@code.kh-super.net:7999/mob/hdkitcore.git", :tag => s.version.to_s}
  s.social_media_url = 'https://code.kh-super.net/projects/MOB/repos/hdkitcore/'
  s.requires_arc     = true
  s.documentation_url = 'https://code.kh-super.net/projects/MOB/repos/hdkitcore/'

  s.platform         = :ios, '9.0'
  s.pod_target_xcconfig = { 'OTHER_LDFLAGS' => '-lObjC' }

  $lib = ENV['use_lib']
  $lib_name = ENV["#{s.name}_use_lib"]
  if $lib || $lib_name
    puts '--------- HDKitCore binary -------'

    s.frameworks       = 'Foundation', 'UIKit', 'CoreGraphics', 'QuartzCore', 'AVFoundation'
    s.resources = "#{s.name}-#{s.version}/ios/#{s.name}.framework/Versions/A/Resources/*.bundle"
    s.ios.vendored_framework = "#{s.name}-#{s.version}/ios/#{s.name}.framework"
  else
    puts '....... HDKitCore source ........'

    s.frameworks       = 'Foundation', 'UIKit', 'CoreGraphics', 'QuartzCore'
    s.source_files     = 'HDKitCore/HDKitCore.h'
    s.resource_bundles = {'HDKitCoreResources' => ['HDKitCore/Resources/*.*']}

    s.subspec 'Core' do |ss|
      ss.source_files = 'HDKitCore/HDKitCore.h', 'HDKitCore/Core', 'HDKitCore/Extensions', 'HDKitCore/Extensions/**/*'
      ss.dependency 'HDKitCore/HDWeakObjectContainer'
      ss.dependency 'HDKitCore/HDLog'
      ss.dependency 'HDKitCore/HDRuntime'
      ss.frameworks = 'AVFoundation'
    end
    
    s.subspec 'WNApp' do |ss|
      ss.source_files = 'HDKitCore/WNApp/*'
    end

    s.subspec 'UnicodeLog' do |ss|
      ss.source_files = 'HDKitCore/UnicodeLog'
    end

    s.subspec 'HDRuntime' do |ss|
      ss.source_files = 'HDKitCore/Core/Runtime','HDKitCore/Extensions/NSMethodSignature+HDKitCore.{h,m}'
      ss.dependency 'HDKitCore/HDLog'
    end

    s.subspec 'MethodSwizzle' do |ss|
      ss.source_files = 'HDKitCore/Extensions/NSObject/NSObject+HD_Swizzle.{h,m}'
    end

    s.subspec 'DispatchMainQueueSafe' do |ss|
      ss.source_files = 'HDKitCore/DispatchMainQueueSafe'
    end

    s.subspec 'HDWeakObjectContainer' do |ss|
      ss.source_files = 'HDKitCore/HDWeakObjectContainer/HDWeakObjectContainer.{h,m}'
    end

    s.subspec 'HDFrameLayout' do |ss|
      ss.source_files = 'HDKitCore/HDFrameLayout'
    end

    s.subspec 'HDFunctionThrottle' do |ss|
      ss.source_files = 'HDKitCore/HDFunctionThrottle'
    end

    s.subspec 'HDLog' do |ss|
      ss.source_files = 'HDKitCore/HDLog'
    end

    s.subspec 'MultipleDelegates' do |ss|
      ss.source_files = 'HDKitCore/MultipleDelegates'
      ss.dependency 'HDKitCore/Core'
    end

    s.subspec 'HDMediator' do |ss|
      ss.source_files = 'HDKitCore/HDMediator'
    end

    s.subspec 'HDWeakTimer' do |ss|
      ss.source_files = 'HDKitCore/HDWeakTimer'
    end

    s.subspec 'KVOController' do |ss|
      ss.source_files = 'HDKitCore/FBKVOController'
    end

    s.subspec 'HDAnimation' do |ss|
      ss.source_files = 'HDKitCore/HDAnimation'
    end

    s.subspec 'Extensions' do |ss|
      ss.source_files = 'HDKitCore/Extensions', 'HDKitCore/Extensions/**/*'
      ss.dependency 'HDKitCore/Core'

      ss.subspec 'UIView' do |sss|
        sss.source_files = 'HDKitCore/Extensions/UIView'
      end

      ss.subspec 'NSString' do |sss|
        sss.source_files = 'HDKitCore/Extensions/NSString'
      end

      ss.subspec 'UIColor' do |sss|
        sss.source_files = 'HDKitCore/Extensions/UIColor'
        sss.dependency 'HDKitCore/Extensions/NSString'
      end

      ss.subspec 'UIImage' do |sss|
        sss.source_files = 'HDKitCore/Extensions/UIImage'
        sss.dependency 'HDKitCore/Extensions/NSString'
      end

      ss.subspec 'UIButton' do |sss|
        sss.source_files = 'HDKitCore/Extensions/UIButton'
      end
      
      ss.subspec 'NSArray' do |sss|
        sss.source_files = 'HDKitCore/Extensions/NSArray'
      end

    end

    s.subspec 'HDAlertQueueManager' do |ss|
      ss.source_files = 'HDKitCore/HDAlertQueueManager'
      ss.dependency 'HDKitCore/Extensions'
      ss.dependency 'HDKitCore/DispatchMainQueueSafe'
    end
    
  end

end
