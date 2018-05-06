require 'spec_helper'

describe AppInfo::Parser::InfoPlist do
  let(:ipa) { AppInfo::Parser::IPA.new(IPA_IPHONE_FILE) }
  subject { AppInfo::Parser::InfoPlist.new(ipa.app_path) }

  it { expect(subject.build_version).to eq('5') }
  it { expect(subject.release_version).to eq('1.2.3') }
  it { expect(subject.name).to eq('AppInfoDemo') }
  it { expect(subject.bundle_name).to eq('AppInfoDemo') }
  it { expect(subject.display_name).to be_nil }
  it { expect(subject.identifier).to eq('com.icyleaf.AppInfoDemo') }
  it { expect(subject.bundle_id).to eq('com.icyleaf.AppInfoDemo') }
  it { expect(subject.device_type).to eq('iPhone') }
  it { expect(subject.info).to be_kind_of Hash }
end
