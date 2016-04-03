require "opal/cutest/version"

if RUBY_ENGINE == 'opal'
  module Kernel
    def print(*args)
      puts(*args)
    end

    module Thread
      def self.current
        @current ||= {}
      end
    end
  end
else
  Opal.use_gem 'cutest'
  Opal.append_path File.expand_path('../..', __FILE__)
  Opal.append_path File.expand_path('../../..', __FILE__)
end

require 'cutest'

class Cutest
  # we use mutex instead of Thead as it's more thread safe.
  class CutestCache
    # Create a new thread safe cache.
    def initialize(options = false)
      @mutex = Mutex.new if RUBY_ENGINE != 'opal'
      @hash = options || {}
    end

    # Make getting value from underlying hash thread safe.
    def [](key)
      if RUBY_ENGINE == 'opal'
        @hash[key]
      else
        @mutex.synchronize { @hash[key] }
      end
    end

    # Make setting value in underlying hash thread safe.
    def []=(key, value)
      if RUBY_ENGINE == 'opal'
        @hash[key] = value
      else
        @mutex.synchronize { @hash[key] = value }
      end
    end
  end
end

module Kernel
  private

  def cutest
    # we use mutex instead of Thead as it's more thread safe.
    @cutest ||= Cutest::CutestCache.new(prepare: [])
  end
end

if RUBY_ENGINE == 'opal'
  require 'opal/opal/cutest'
end
