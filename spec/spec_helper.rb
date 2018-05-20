$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'app_info'
require 'fileutils'

APK_FILE        = 'spec/fixtures/apps/android.apk'.freeze
APK_TV_FILE     = 'spec/fixtures/apps/tv.apk'.freeze
APK_WEAR_FILE   = 'spec/fixtures/apps/wear.apk'.freeze
IPA_IPHONE_FILE = 'spec/fixtures/apps/iphone.ipa'.freeze
IPA_IPAD_FILE   = 'spec/fixtures/apps/ipad.ipa'.freeze
APP_FILE        = 'spec/fixtures/apps/AppInfoDemo.app'.freeze

LIST_OF_APP_FILE = %w[
  _CodeSignature
  _CodeSignature/CodeResources
  AppInfoDemo
  archived-expanded-entitlements.xcent
  Base.lproj
  Base.lproj/LaunchScreen.storyboardc
  Base.lproj/LaunchScreen.storyboardc/01J-lp-oVM-view-Ze5-6b-2t3.nib
  Base.lproj/LaunchScreen.storyboardc/Info.plist
  Base.lproj/LaunchScreen.storyboardc/UIViewController-01J-lp-oVM.nib
  Base.lproj/Main.storyboardc
  Base.lproj/Main.storyboardc/BYZ-38-t0r-view-8bC-Xf-vdC.nib
  Base.lproj/Main.storyboardc/Info.plist
  Base.lproj/Main.storyboardc/UIViewController-BYZ-38-t0r.nib
  embedded.mobileprovision
  Info.plist
  PkgInfo
  Test
  Test/MobileConfig.json
].map { |item| "spec/fixtures/apps/AppInfoDemo.app/#{item}" }
