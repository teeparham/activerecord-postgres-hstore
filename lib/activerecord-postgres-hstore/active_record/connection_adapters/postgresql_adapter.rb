module ActiveRecord
  # This error class is used when the user passes a wrong value to a hstore column.
  # Hstore columns accepts hashes or hstore valid strings. It is validated with
  # String#valid_hstore? method.
  class HstoreTypeMismatch < ActiveRecord::ActiveRecordError
  end

  module ConnectionAdapters
    class PostgreSQLAdapter < AbstractAdapter
      def native_database_types_with_hstore
        native_database_types_without_hstore.merge({:hstore => { :name => "hstore" }})
      end

      # Quotes correctly a hstore column value.
      def quote_with_hstore(value, column = nil)
        if value && column && column.sql_type == 'hstore'
          raise HstoreTypeMismatch, "#{column.name} must have a Hash or a valid hstore value (#{value})" unless value.kind_of?(Hash) || value.valid_hstore?
          return quote_without_hstore(value.to_hstore, column)
        end
        quote_without_hstore(value,column)
      end

      alias_method_chain :quote, :hstore
      alias_method_chain :native_database_types, :hstore
    end

  end
end