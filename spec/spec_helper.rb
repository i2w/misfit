if ENV['SIMPLECOV']
  require 'simplecov'
  SimpleCov.start do
    add_filter "_spec.rb"
  end
end

require 'rspec'
require_relative '../lib/misfit'