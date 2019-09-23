Rake::Task.define_task(:environment)

require 'dynamoid/tasks'
require 'jets'

Dir.glob("#{Jets.root}/lib/tasks/*.rake").each { |r| import r }

Jets.load_tasks
