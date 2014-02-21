require 'active_record'
require 'active_mapper'

Dir['./spec/support/**/*.rb'].each { |f| require f }

# stop deprecation message
I18n.enforce_available_locales = false

class CreateUsers < ActiveRecord::Migration
  def up
    create_table :users do |t|
      t.string :name
      t.integer :age
      t.timestamps
    end
  end
end

def setup_active_record(name)
  db = "./spec/support/db/#{name}.sqlite3"

  before(:all) do
    ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: db)
    CreateUsers.new.migrate(:up)
  end

  after(:all) do
    File.delete(db)
  end
end
