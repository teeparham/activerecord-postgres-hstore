module ActiveRecord
  module ConnectionAdapters
    module SchemaStatements

      # Installs hstore by creating the Postgres extension
      # if it does not exist
      #
      def install_hstore
        execute "CREATE EXTENSION IF NOT EXISTS hstore"
      end

      # Uninstalls hstore by dropping Postgres extension if it exists
      #
      def uninstall_hstore
        execute "DROP EXTENSION IF EXISTS hstore"
      end

      # Adds a GiST or GIN index to a table which has an hstore column.
      #
      # Example:
      #   add_hstore_index :people, :info, :type => :gin
      #
      # Options:
      #   :type  = :gist (default) or :gin
      #
      # See http://www.postgresql.org/docs/9.2/static/textsearch-indexes.html for more information.
      #
      def add_hstore_index(table_name, column_name, options = {})
        index_name, index_type, index_columns = add_index_options(table_name, column_name, options)
        index_type = index_type.present? ? index_type : 'gist'
        execute "CREATE INDEX #{index_name} ON #{table_name} USING #{index_type}(#{column_name})"
      end

      # Removes a GiST or GIN index of a table which has an hstore column.
      #
      # Example:
      #   remove_hstore_index :people, :info
      #
      def remove_hstore_index(table_name, options = {})
        index_name = index_name_for_remove(table_name, options)
        execute "DROP INDEX #{index_name}"
      end

    end
  end
end