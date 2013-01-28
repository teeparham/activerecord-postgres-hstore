module ActiveRecord
  module ConnectionAdapters
    class PostgreSQLColumn < Column
      # Does the type casting from hstore columns using String#from_hstore or Hash#from_hstore.
      def type_cast_code_with_hstore(var_name)
        type == :hstore ? "#{var_name}.from_hstore" : type_cast_code_without_hstore(var_name)
      end

      # Adds the hstore type for the column.
      def simplified_type_with_hstore(field_type)
        field_type == 'hstore' ? :hstore : simplified_type_without_hstore(field_type)
      end

      alias_method_chain :type_cast_code, :hstore
      alias_method_chain :simplified_type, :hstore
    end
  end
end
