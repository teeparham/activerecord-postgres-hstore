module ActiveRecord
  module ConnectionAdapters
    class TableDefinition

      # Adds hstore type for migrations. So you can add columns to a table like:
      #   create_table :people do |t|
      #     ...
      #     t.hstore :info
      #     ...
      #   end
      def hstore(*args)
        options = args.extract_options!
        column_names = args
        column_names.each { |name| column(name, 'hstore', options) }
      end

    end
  end
end
