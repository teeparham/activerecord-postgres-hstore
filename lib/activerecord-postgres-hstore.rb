require 'active_support'

if RUBY_PLATFORM == "jruby"
  require 'activerecord-jdbcpostgresql-adapter'
else
  require 'pg'
end

if defined? Rails
  require "rails/hstore_railtie"
else
  ActiveSupport.on_load :active_record do
    require "active_record/base"
    require "active_record/connection_adapters/postgresql_adapter"
    require "active_record/connection_adapters/postgresql_column"
    require "active_record/connection_adapters/schema_statements"
    require "active_record/connection_adapters/table"
    require "active_record/connection_adapters/table_definition"
  end
end

require "core_ext/string"
require "core_ext/hash"
require "active_record/coders/hstore"
