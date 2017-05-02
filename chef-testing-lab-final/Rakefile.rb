require 'kitchen/rake_tasks'
require 'rspec/core/rake_task'

module Lab
    module Utils
        def self.recreate_dir(dir)
            if File.directory?(dir)
                puts("Removing #{dir}")
                FileUtils.remove_dir(dir, true)
            end
            
            FileUtils.mkpath(dir)
        end
    end

    module Build
        module Constants
            def self.build_dir
                return 'build'
            end

            def self.vendor_dir
                return File.join(self.build_dir, 'vendor')
            end
        end
    end
end

desc "Remove build artifacts"
task :clean do
    FileUtils.remove_dir(Lab::Build::Constants.build_dir, true)
    FileUtils.remove('Berksfile.lock') if File.exists?('Berksfile.lock')
end

desc "Fetch dependent cookbooks into #{Lab::Build::Constants.vendor_dir} using Berkshelf"
task :fetch_cookbooks do
    Lab::Utils.recreate_dir(Lab::Build::Constants.vendor_dir)
    puts("Fetching dependent cookbooks to #{Lab::Build::Constants.vendor_dir}")
    system("berks vendor #{Lab::Build::Constants.vendor_dir}")
end

desc "Execute cookbook unit tests. Requires that all dependencies be fetched first."
RSpec::Core::RakeTask.new(:test) do |t|
  t.pattern = "**/*_spec.rb"
  t.rspec_opts = "--color --default-path cookbooks/*/test/unit/ --require ./spec_helper"
end

Kitchen::RakeTasks.new()