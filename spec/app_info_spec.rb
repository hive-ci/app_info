require 'spec_helper'
require 'securerandom'

describe AppInfo do
  let(:apk_file) { APK_FILE }
  let(:ipa_file) { IPA_IPHONE_FILE }
  let(:app_file) { APP_FILE }

  it 'should parse when file extion is .ipa' do
    file = AppInfo.parse(ipa_file)
    expect(file.class).to eq(AppInfo::Parser::IOS::IPA)
  end

  it 'should parse when file extion is .app' do
    file = AppInfo.parse(app_file)
    expect(file.class).to eq(AppInfo::Parser::IOS::IPA)
  end

  it 'should dump when file extion is .apk' do
    file = AppInfo.dump(ipa_file)
    expect(file.class).to eq(AppInfo::Parser::IOS::IPA)
  end

  it 'should throwa an exception when file is not exist' do
    file = 'path/to/your/file'
    expect do
      AppInfo.parse(file)
    end.to raise_error(AppInfo::NotFoundError)
  end

  %w[txt pdf zip rar].each do |ext|
    it "should throwa an exception when file is .#{ext}" do
      filename = "#{SecureRandom.uuid}.#{ext}"
      file = Tempfile.new(filename)

      expect do
        AppInfo.parse(file.path)
      end.to raise_error(AppInfo::NotAppError)
    end
  end
end
