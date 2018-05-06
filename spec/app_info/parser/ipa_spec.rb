require 'spec_helper'

describe AppInfo::Parser::IPA do
  describe '#iPhone' do
    let(:file) { IPA_IPHONE_FILE }
    subject { AppInfo::Parser::IPA.new(file) }

    context 'parse' do
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
      it { expect(subject.metadata?).to be false }
      it { expect(subject.stored?).to be false }
      it { expect(subject.info).to be_kind_of AppInfo::Parser::InfoPlist }
      it { expect(subject.mobileprovision).to be_kind_of AppInfo::Parser::MobileProvision }
    end
  end

  describe '#iPad' do
    let(:file) { IPA_IPAD_FILE }
    subject { AppInfo::Parser::IPA.new(file) }

    context 'parse in macOS' do
      it { expect(subject.os).to eq 'iOS' }
      it { expect(subject).not_to be_iphone }
      it { expect(subject).to be_ipad }
      it { expect(subject).not_to be_universal }
      it { expect(subject.file).to eq file }
      it { expect(subject.build_version).to eq('1') }
      it { expect(subject.release_version).to eq('1.0') }
      it { expect(subject.name).to eq('bundle') }
      it { expect(subject.bundle_name).to eq('bundle') }
      it { expect(subject.display_name).to be_nil }
      it { expect(subject.identifier).to eq('com.icyleaf.bundle') }
      it { expect(subject.bundle_id).to eq('com.icyleaf.bundle') }
      it { expect(subject.device_type).to eq('iPad') }

      if AppInfo::Parser.mac?
        it { expect(subject.release_type).to eq('inHouse') }
        it { expect(subject.build_type).to eq('inHouse') }
        it { expect(subject.devices).to be_nil }
        it { expect(subject.team_name).to eq('QYER Inc') }
        it { expect(subject.profile_name).to eq('XC: *') }
        it { expect(subject.expired_date).not_to be_nil }
        it { expect(subject.distribution_name).to eq('XC: * - QYER Inc') }
      end

      it { expect(subject.mobileprovision?).to be true }
      it { expect(subject.metadata).to be_nil }
      it { expect(subject.metadata?).to be false }
      it { expect(subject.stored?).to be false }
      it { expect(subject.ipad?).to be true }
      it { expect(subject.info).to be_kind_of AppInfo::Parser::InfoPlist }
      it { expect(subject.mobileprovision).to be_kind_of AppInfo::Parser::MobileProvision }
    end

    context 'parse without macOS' do
      before do
        allow(AppInfo::Parser).to receive('mac?').and_return(false)
      end

      it { expect(subject.os).to eq 'iOS' }
      it { expect(subject).not_to be_iphone }
      it { expect(subject).to be_ipad }
      it { expect(subject).not_to be_universal }
      it { expect(subject.file).to eq file }
      it { expect(subject.build_version).to eq('1') }
      it { expect(subject.release_version).to eq('1.0') }
      it { expect(subject.name).to eq('bundle') }
      it { expect(subject.bundle_name).to eq('bundle') }
      it { expect(subject.display_name).to be_nil }
      it { expect(subject.identifier).to eq('com.icyleaf.bundle') }
      it { expect(subject.bundle_id).to eq('com.icyleaf.bundle') }
      it { expect(subject.device_type).to eq('iPad') }

      it { expect(subject.release_type).to be_nil }
      it { expect(subject.build_type).to be_nil }
      it { expect(subject.devices).to be_nil }
      it { expect(subject.team_name).to be_nil }
      it { expect(subject.profile_name).to be_nil }
      it { expect(subject.expired_date).to be_nil }
      it { expect(subject.distribution_name).to be_nil }

      it { expect(subject.mobileprovision?).to be true }
      it { expect(subject.metadata).to be_nil }
      it { expect(subject.metadata?).to be false }
      it { expect(subject.stored?).to be false }
      it { expect(subject.ipad?).to be true }
      it { expect(subject.info).to be_kind_of AppInfo::Parser::InfoPlist }
      it { expect(subject.mobileprovision).to be_kind_of AppInfo::Parser::MobileProvision }
    end
  end
end
