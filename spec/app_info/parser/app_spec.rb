require 'spec_helper'

describe AppInfo::Parser::IOS::IPA do
  describe '#APP' do
    let(:file) { APP_FILE }
    let(:missing_file) { 'empty.plist' }
    subject { AppInfo::Parser::IOS::IPA.new(file) }

    context 'parse' do
      it { expect(subject.get_all_file_paths).to match_array(LIST_OF_APP_FILE) }
      it { subject.read_file(file: 'Test/MobileConfig.json') == IO.read('spec/fixtures/config/MobileConfig.json') }

      it { expect(subject.json(file: 'Test/MobileConfig.json')['lastModified']).to eq('2017-06-15T12:45:16.340Z') }
      it { expect(subject.json(file: 'Test/MobileConfig.json')['lastModified']).to be_kind_of String }
      it { expect(subject.json(file: 'Test/MobileConfig.json')['analytics']['ssl']).to be true }
      it { expect(subject.json(file: 'Test/MobileConfig.json')['analytics']['privacyDefault']).to eq('optedin') }
      it { expect(subject.json(file: 'Test/MobileConfig.json')['analytics']['lastModified']).to be_nil }

      it { expect(subject.get_file_path('Info.plist')).to eq('spec/fixtures/apps/AppInfoDemo.app/Info.plist') }
      it { expect(subject.get_file_path(missing_file)).to be_nil }

      it { expect(subject.os).to eq 'iOS' }
      it { expect(subject).to be_iphone }
      it { expect(subject).not_to be_ipad }
      it { expect(subject).not_to be_universal }
      it { expect(subject.file).to eq file }
      it { expect(subject.build_version).to eq('5') }
      it { expect(subject.release_version).to eq('1.2.3') }
      it { expect(subject.name).to eq('AppInfoDemo') }
      it { expect(subject.bundle_name).to eq('AppInfoDemo') }
      it { expect(subject.display_name).to be_nil }
      it { expect(subject.identifier).to eq('com.icyleaf.AppInfoDemo') }
      it { expect(subject.bundle_id).to eq('com.icyleaf.AppInfoDemo') }
      it { expect(subject.device_type).to eq('iPhone') }

      if AppInfo::Parser.mac?
        it { expect(subject.release_type).to eq('AdHoc') }
        it { expect(subject.build_type).to eq('AdHoc') }
        it { expect(subject.devices).to be_kind_of Array }
        it { expect(subject.team_name).to eq('QYER Inc') }
        it { expect(subject.profile_name).to eq('iOS Team Provisioning Profile: *') }
        it { expect(subject.expired_date).not_to be_nil }
        it { expect(subject.distribution_name).not_to be_nil }
      end

      it { expect(subject.mobileprovision?).to be true }
      it { expect(subject.metadata).to be_nil }
      it { expect(subject.app_store?).to be false }
      it { expect(subject.info).to be_kind_of AppInfo::Parser::InfoPlist }
      it { expect(subject.mobileprovision).to be_kind_of AppInfo::Parser::MobileProvision }
    end
  end
end
