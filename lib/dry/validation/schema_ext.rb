# frozen_string_literal: true

require 'dry/schema/key'
require 'dry/schema/key_map'
require 'dry/schema/dsl'

module Dry
  module Schema
    class Path
      # @api private
      def multi_value?
        last.is_a?(Array)
      end

      # @api private
      def expand
        to_a[0..-2].product(last).map { |spec| self.class[spec] }
      end
    end

    # @api private
    #
    # TODO: this should be moved to dry-schema at some point
    class Key
      # @api private
      def to_dot_notation
        [name.to_s]
      end

      # @api private
      class Hash < Key
        # @api private
        def to_dot_notation
          [name].product(members.flat_map(&:to_dot_notation)).map { |e| e.join(DOT) }
        end
      end
    end

    # @api private
    class KeyMap
      # @api private
      def to_dot_notation
        @to_dot_notation ||= map(&:to_dot_notation).flatten
      end
    end

    # @api public
    #
    # TODO: this should be moved to dry-schema at some point
    class DSL
      # @api public
      #
      # add the specified schemas rules and keys to our own
      def compose(*schemas)
        check_same_processor_type!(schemas)
        parents.concat(schemas)
      end

      private

      # @api private
      #
      # raise InvalidSchemaError unless schemas have the smae processor type
      def check_same_processor_type!(schemas)
        processors = [processor_type, *schemas.map(&:class)]
        return if processors.uniq.length == 1

        raise InvalidSchemaError, <<-STR.gsub(/\s+/,' ').chomp
          schema compositions must have the same processor type as the
          composing schema (#{processors[0]}),
          but they were #{processors[1..-1]}
        STR
      end
    end
  end
end
