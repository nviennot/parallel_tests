require 'parallel_tests'
require 'parallel_tests/rspec/logger_base'

class RSpec::Core::World
  def announce_filters
  end
end

class ParallelTests::RSpec::RuntimeLogger < ParallelTests::RSpec::LoggerBase
  def initialize(*args)
    super
    @example_times = Hash.new(0)
    @group_nesting = 0
  end

  def example_started(*args)
    @time = ParallelTests.now
    super
  end

  def example_passed(example)
    @example_times[example.location] += ParallelTests.now - @time
    super
  end

  def dump_summary(*args);end
  def dump_failures(*args);end
  def dump_failure(*args);end
  def dump_pending(*args);end

  def start_dump(*args)
    return unless ENV['TEST_ENV_NUMBER'] #only record when running in parallel
    # TODO: Figure out why sometimes time can be less than 0
    lock_output do
      @example_times.each do |file, time|
        relative_path = file.sub(/^#{Regexp.escape Dir.pwd}\//,'')
        @output.puts "#{relative_path}:#{time > 0 ? time : 0}"
      end
    end
    @output.flush
  end
end
