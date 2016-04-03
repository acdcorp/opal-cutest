class Cutest
  def self.run(files)
    files.each do |file|
      run_file(file)
    end
  end

  def self.run_file(file)
    begin
      require file

    rescue LoadError, SyntaxError
      display_error

    rescue StandardError
      trace = $!.backtrace
      pivot = trace.index { |line| line.match(file) }

      puts "\n  test: %s" % cutest[:test]

      if pivot
        other = trace[0..pivot].select { |line| line !~ FILTER }
        other.reverse.each { |line| display_trace(line) }
      else
        display_trace(trace.first)
      end

      display_error
    end
  end
end

module Kernel
  private

  # Stop the tests and raise an error where the message is the last line
  # executed before flunking.
  def flunk(message = nil)
    raise Cutest::AssertionFailed.new(message)
  end
end
