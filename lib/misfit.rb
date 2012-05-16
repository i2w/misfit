require 'active_support/concern'
require 'active_support/core_ext'

module Misfit
  extend ActiveSupport::Concern
  
  included do inherit_from_misfit end
  
  def self.exception_class
    StandardError
  end
  
  attr_accessor :data
  
  module ClassMethods
    def new message, data = nil, *backtrace
      wrap_exception exception_class.exception(message, *backtrace), data
    end
    
    def exception message, *args
      new message, nil, *args
    end
    
    def wrap *args, &block
      if block
        wrap_block &block
      else
        wrap_exception *args
      end
    end
    
    def exception_class klass = nil
      @exception_class = klass if klass
      @exception_class
    end
    
  private
    def wrap_exception exception, data = nil
      exception.tap do |e|
        e.extend self unless e.is_a?(self)
        e.data = data if data
      end
    end
    
    def wrap_block
      yield
    rescue Exception => exception
      raise wrap_exception(exception)
    end
    
    # when an exception module is included, set up this module
    # as an exception module itself, and 'inherit' the exception_class
    def inherit_from_misfit
      extend ActiveSupport::Concern
      exception_class ancestors[1].exception_class
      included do inherit_from_misfit end
    end
  end
end