module ActiveModel
  class Serializer
    class DSL
      attr_reader :serializer_class

      def initialize(serializer_class)
        @serializer_class = serializer_class
      end

      def attributes(*names)
        serializer_class._attributes.concat names

        names.each do |name|
          serializer_class.send :define_method, name do
            object.read_attribute_for_serialization name
          end unless serializer_class.method_defined? name
        end
      end

      def has_one(*names)
        associate Association::HasOne, *names
      end

      def has_many(*names)
        associate Association::HasMany, *names
      end

      private

      def associate(klass, *names)
        options = names.extract_options!

        names.each do |name|
          serializer_class.send :define_method, name do
            object.send name
          end unless serializer_class.method_defined? name

          serializer_class._associations[name] = klass.new name, options
        end
      end
    end
  end
end