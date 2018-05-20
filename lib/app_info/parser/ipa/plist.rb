require 'cfpropertylist'

module AppInfo
  module Parser
    class Plist
      def read(file_path)
        @plist = CFPropertyList.native_types(CFPropertyList::List.new(file: file_path).value)
      end
    end
  end
end
