require 'active_mapper/mapper'
require 'active_mapper/relation'
require 'active_mapper/adapter'
require 'active_mapper/version'

module ActiveMapper
  def self.[](klass)
    mappers[klass] ||= Class.new(ActiveMapper::Mapper).new(klass, adapter)
  end

  def self.adapter
    @adapter ||= ActiveMapper::Adapter::Memory.new
  end

  def self.adapter=(adapter)
    @adapter = adapter
  end

  private

  def self.mappers
    @mappers ||= {}
  end
end