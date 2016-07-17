def run(cmd)
  system(cmd) or raise "RAKE TASK FAILED: #{cmd}"
end

namespace "test" do
  desc "Run unit tests"
  task :unit do |t|
    run('bundle exec scan -s Sinope')
  end

  namespace "integration" do
    desc "setup integration tests"
    task :setup do |t|
      run 'git clone https://github.com/younata/Pasiphae'
      run 'cd Pasiphae && bundle install --gemfile=./Gemfile && bundle exec rake db:migrate && PASIPHAE_APPLICATION_TOKEN=\'test\' bundle exec rails s &'
      run 'sleep 5'
    end

    desc "run integration tests"
    task :run do |t|
      run('bundle exec scan -s SinopeIntegrationTests')
    end

    desc "Setup and run integration tests"
    task :setup_and_run => [:setup, :run]
  end
end

task default: ["test:unit"]
