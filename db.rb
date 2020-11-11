require 'sequel'
require './environment'

class DBConnection
  def initialize
    base = "postgres://#{ENV['DB_USER']}:#{ENV['DB_PASS']}@#{ENV['DB_HOST']}:#{ENV['DB_PORT']}"
    @connection_string = base + "/" + ENV['DB_NAME']
    @admin_connection_string = base + "/" + "postgres"
  end

  attr_accessor :connection_string, :admin_connection_string

  def connect(admin = false)
    db = Sequel.connect(admin ? @admin_connection_string : @connection_string)
    db.extension :pg_json
    db.extension(:connection_validator)
    db.pool.connection_validation_timeout = 280
    db
  end
end
