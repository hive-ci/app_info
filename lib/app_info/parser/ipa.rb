require 'pngdefry'
require 'fileutils'
require 'securerandom'
require 'cfpropertylist'
require 'app_info/core_ext/object/try'

module AppInfo
  module Parser
    # IPA parser
    class IPA
      attr_accessor :file, :app_path

      # iOS Export types
      module ExportType
        DEBUG   = 'Debug'.freeze
        ADHOC   = 'AdHoc'.freeze
        INHOUSE = 'inHouse'.freeze
        RELEASE = 'Release'.freeze
        UNKOWN  = nil
      end

      def initialize(file)
        @file     = file
        @app_path = app_path || file
      end

      def app_path
        path = if @file.downcase.include? '.app'
                 '*.app'
               else
                 File.join(contents, 'Payload', '*.app')
               end

        @app_path ||= Dir.glob(path).first
      end

      def metadata_path
        @metadata_path ||= File.join(@contents || @app_path, 'iTunesMetadata.plist')
      end

      def info
        @info ||= InfoPlist.new(@app_path)
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
        stored? ? ExportType::RELEASE : build_type
      end

      def build_type
        return ExportType::UNKOWN unless AppInfo::Parser.mac?

        ExportType::DEBUG unless mobileprovision?
        devices ? ExportType::ADHOC : ExportType::INHOUSE
      end

      def stored?
        metadata? ? true : false
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
        File.exist?mobileprovision_path
      end

      def mobileprovision_path
        filename = 'embedded.mobileprovision'
        @mobileprovision_path ||= File.join(@file, filename)

        unless File.exist? @mobileprovision_path
          @mobileprovision_path = File.join(app_path, filename)
        end

        @mobileprovision_path
      end

      def metadata
        return unless metadata?

        @metadata ||= CFPropertyList.native_types(CFPropertyList::List.new(file: metadata_path).value)
      end

      def metadata?
        File.exist?(metadata_path)
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
        unless @contents
          @contents = "#{Dir.mktmpdir}/AppInfo-ios-#{SecureRandom.hex}"

          Zip::File.open(@file) do |zip_file|
            zip_file.each do |file|
              file_path = File.join(@contents, file.name)
              FileUtils.mkdir_p(File.dirname(file_path))
              zip_file.extract(file, file_path) unless File.exist?(file_path)
            end
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
