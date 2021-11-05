# frozen_string_literal: true

module GoogleServices
  class Drive
    def initialize
      prepare_drive_config_json
      @drive = GoogleDrive.saved_session('config.json')
    end

    def upload_file(file_path, folder, destination_name=nil)
      destination_name = File.basename(file_path) if destination_name.nil?

      folder = @drive.folders.find { |f| f.name == folder }
      folder.upload_from_file(file_path, destination_name, convert: false)
    end

    private

    def prepare_drive_config_json
      content = {
        client_id: ENV['DRIVE_CLIENT_ID'],
        client_secret: ENV['DRIVE_CLIENT_SECRET'],
        scope: [
          "https://www.googleapis.com/auth/drive"
        ],
        refresh_token: ENV['DRIVE_REFRESH_TOKEN']
      }

      File.open('config.json', 'w') do |f|
        f.write(content.to_json)
      end
    end
  end
end