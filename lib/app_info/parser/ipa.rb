require 'app_info/core_ext/object/try'
require 'fileutils'
require 'json'
require 'pngdefry'
require 'securerandom'

module AppInfo
  module Parser
    module IOS
      INFO_PLIST      = 'Info.plist'.freeze
      ITUNES_METADATA = 'iTunesMetadata.plist'.freeze
      MOBILEPROVISION = 'embedded.mobileprovision'.freeze

      DEBUG   = 'Debug'.freeze
      ADHOC   = 'AdHoc'.freeze
      INHOUSE = 'inHouse'.freeze
      RELEASE = 'Release'.freeze
      UNKOWN  = nil

      class IPA
        attr_accessor :file, :app_path

        def initialize(file)
          @file = file

          path = if File.extname(@file).downcase.include?('.app')
                   @file
                 else
                   File.join(contents, 'Payload', '*.app')
                 end

          @app_path ||= Dir.glob(path).first
        end

        def metadata_path
          @metadata_path ||= get_file_path(ITUNES_METADATA)
        end

        def mobileprovision_path
          @mobileprovision_path ||= get_file_path(MOBILEPROVISION)
        end

        def metadata
          @metadata ||= read_file(file: ITUNES_METADATA, type: :plist)
        end

        def info
          @info ||= InfoPlist.new(@app_path)
        end

        def plist(options = {})
          read_file(file: options[:file], type: :plist)
            .try(:[], options[:key])
        end

        def json(options = {})
          data = read_file(file: options[:file])

          JSON.parse(data, quirks_mode: true)
        end

        def os
          Parser::Platform::IOS
        end

        def iphone?
          info.iphone?
        end

        def ipad?
          info.ipad?
        end

        def universal?
          info.universal?
        end

        def build_version
          info.build_version
        end

        def release_version
          info.release_version
        end

        def identifier
          info.identifier
        end

        def name
          display_name || bundle_name
        end

        def display_name
          info.display_name
        end

        def bundle_name
          info.bundle_name
        end

        def icons
          info.icons
        end

        def device_type
          info.device_type
        end

        def devices
          mobileprovision.devices
        end

        def team_name
          mobileprovision.team_name
        end

        def team_identifier
          mobileprovision.team_identifier
        end

        def profile_name
          mobileprovision.profile_name
        end

        def expired_date
          mobileprovision.expired_date
        end

        def distribution_name
          "#{profile_name} - #{team_name}" if profile_name && team_name
        end

        def release_type
          app_store? ? RELEASE : build_type
        end

        def build_type
          return UNKOWN unless AppInfo::Parser.mac?

          DEBUG unless mobileprovision?
          devices ? ADHOC : INHOUSE
        end

        def app_store?
          metadata.nil? ? false : true
        end

        def hide_developer_certificates
          mobileprovision.delete('DeveloperCertificates') if mobileprovision?
        end

        def mobileprovision
          return unless mobileprovision?
          return @mobileprovision if @mobileprovision

          file = AppInfo::Parser.mac? ? mobileprovision_path : nil

          @mobileprovision = MobileProvision.new(file)
        end

        def mobileprovision?
          mobileprovision_path.nil? ? false : true
        end

        def get_file_path(file)
          file_path = File.join(@app_path, file)

          return unless File.exist?(file_path)

          file_path
        end

        def get_all_file_paths
          Dir.glob(File.join(@app_path, '**', '*'))
        end

        def read_file(options = {})
          file_path = get_file_path(options[:file])

          return if file_path.nil?

          if options[:type] == :plist
            data = Plist.read(file_path)
          else
            file = File.open(file_path, 'r')
            data = file.read

            file.close
          end

          data
        end

        def cleanup!
          return unless @contents

          FileUtils.rm_rf(@contents)

          @contents      = nil
          @icons         = nil
          @app_path      = nil
          @metadata      = nil
          @metadata_path = nil
          @info          = nil
        end

        alias bundle_id identifier

        private

        def contents
          # source: https://github.com/soffes/lagunitas/blob/master/lib/lagunitas/ipa.rb
          @contents ||= "#{Dir.mktmpdir}/AppInfo-ios-#{SecureRandom.hex}"

          return @contents unless @contents

          Zip::File.open(@file) do |zip_file|
            zip_file.each do |file|
              file_path = File.join(@contents, file.name)
              FileUtils.mkdir_p(File.dirname(file_path))
              zip_file.extract(file, file_path) unless File.exist?(file_path)
            end
          end

          @contents
        end

        def icons_root_path
          iphone = 'CFBundleIcons'.freeze
          ipad   = 'CFBundleIcons~ipad'.freeze

          case device_type
          when 'iPhone'
            [iphone]
          when 'iPad'
            [ipad]
          when 'Universal'
            [iphone, ipad]
          end
        end
      end
    end
  end
end
