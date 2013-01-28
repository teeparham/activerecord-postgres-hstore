module ActiveRecord
  # Adds methods for deleting keys in your hstore columns
  class Base

    # Deletes all keys from a specific column in a model. E.g.
    #   Person.delete_key(:info, :father)
    # The SQL generated will be:
    #   UPDATE "people" SET "info" = delete("info",'father');
    def self.delete_key attribute, key
      raise "invalid attribute #{attribute}" unless column_names.include?(attribute.to_s)
      update_all([%(#{attribute} = delete("#{attribute}",?)),key])
    end

    # Deletes many keys from a specific column in a model. E.g.
    #   Person.delete_key(:info, :father, :mother)
    # The SQL generated will be:
    #   UPDATE "people" SET "info" = delete(delete("info",'father'),'mother');
    def self.delete_keys attribute, *keys
      raise "invalid attribute #{attribute}" unless column_names.include?(attribute.to_s)
      delete_str = "delete(#{attribute},?)"
      (keys.count-1).times{ delete_str = "delete(#{delete_str},?)" }
      update_all(["#{attribute} = #{delete_str}", *keys])
    end

    # Deletes a key in a record. E.g.
    #   witt = Person.find_by_name("Ludwig Wittgenstein")
    #   witt.destroy_key(:info, :father)
    # It does not save the record, so you'll have to do it.
    def destroy_key attribute, key
      raise "invalid attribute #{attribute}" unless self.class.column_names.include?(attribute.to_s)
      new_value = send(attribute)
      new_value.delete(key.to_s)
      send("#{attribute}=", new_value)
      self
    end

    # Deletes a key in a record. E.g.
    #   witt = Person.find_by_name("Ludwig Wittgenstein")
    #   witt.destroy_key(:info, :father)
    # It does save the record.
    def destroy_key! attribute, key
      destroy_key(attribute, key).save
    end

    # Deletes many keys in a record. E.g.
    #   witt = Person.find_by_name("Ludwig Wittgenstein")
    #   witt.destroy_keys(:info, :father, :mother)
    # It does not save the record, so you'll have to do it.
    def destroy_keys attribute, *keys
      for key in keys
        new_value = send(attribute)
        new_value.delete(key.to_s)
        send("#{attribute}=", new_value)
      end
      self
    end

    # Deletes many keys in a record. E.g.
    #   witt = Person.find_by_name("Ludwig Wittgenstein")
    #   witt.destroy_keys!(:info, :father, :mother)
    # It does save the record.
    def destroy_keys! attribute, *keys
      raise "invalid attribute #{attribute}" unless self.class.column_names.include?(attribute.to_s)
      destroy_keys(attribute, *keys).save
    end

    if defined? Rails and Rails.version < '3.1.0'
      # This method is replaced for Rails 3 compatibility.
      # All I do is add the condition when the field is a hash that converts the value
      # to hstore format.
      # IMHO this should be delegated to the column, so it won't be necessary to rewrite all
      # this method.
      def arel_attributes_values(include_primary_key = true, include_readonly_attributes = true, attribute_names = @attributes.keys)
        attrs = {}
        attribute_names.each do |name|
          if (column = column_for_attribute(name)) && (include_primary_key || !column.primary)
            if include_readonly_attributes || (!include_readonly_attributes && !self.class.readonly_attributes.include?(name))
              value = read_attribute(name)
              if self.class.columns_hash[name].type == :hstore && value && value.is_a?(Hash)
                value = value.to_hstore # Done!
              elsif value && self.class.serialized_attributes.has_key?(name) && (value.acts_like?(:date) || value.acts_like?(:time) || value.is_a?(Hash) || value.is_a?(Array))
                value = value.to_yaml
              end
              attrs[self.class.arel_table[name]] = value
            end
          end
        end
        attrs
      end
    end

  end
end