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
    # when called with an exception, makes the exception a <self>
    # when called with a block, any exceptions raised in the block will be wrapped as <self>
    def wrap *args, &block
      if block
        wrap_block &block
      else
        wrap_exception *args
      end
    end

    def new message = nil, data = nil, *backtrace
      wrap_exception exception_class.exception(message, *backtrace), data
    end

    def exception message = nil, *args
      new message, nil, *args
    end

    def exception_class klass = nil
      @exception_class = klass if klass
      @exception_class
    end

    def misfit?
      true
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

  def inspect
    super.sub(/:/," (#{misfits.map(&:name).join(', ')}):")
  end

  # this is here solely because of the way rspec instantiates exception objects in stubs
  def initialize *args
    super
  end

  def misfits
    singleton_class.included_modules.select {|m| m.respond_to?(:misfit?) && m.misfit? }
  end
end
