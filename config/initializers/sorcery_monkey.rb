# Monkey patch to prevent Sorcery generator to crash with Rails 7 projects
module Sorcery
  module Generators
    class InstallGenerator < Rails::Generators::Base
      # Define the next_migration_number method (necessary for the migration_template method to work)
      def self.next_migration_number(dirname)
        if ActiveRecord.timestamped_migrations
          sleep 1 # make sure each time we get a different timestamp
          Time.new.utc.strftime('%Y%m%d%H%M%S')
        else
          format('%.3d', (current_migration_number(dirname) + 1))
        end
      end
    end
  end
end
