require "mobility/backend_resetter"
require "mobility/plugins/fallthrough_accessors"

module Mobility
  module Plugins
=begin

Dirty tracking for Mobility attributes. See class-specific implementations for
details.

@see Mobility::Plugins::ActiveModel::Dirty
@see Mobility::Plugins::Sequel::Dirty

@note Dirty tracking can have unexpected results when combined with fallbacks.
  A change in the fallback locale value will not mark an attribute falling
  through to that locale as changed, even though it may look like it has
  changed. However, when the value for the current locale is changed from nil
  or blank to a new value, the change will be recorded as a change from that
  fallback value, rather than from the nil or blank value. The specs are the
  most reliable source of information on the interaction between dirty tracking
  and fallbacks.

=end
    module Dirty
      class << self
        # Applies dirty plugin to attributes for a given option value.
        # @param [Attributes] attributes
        # @param [Boolean] option Value of option
        # @raise [ArgumentError] if model class does not support dirty tracking
        def apply(attributes, option)
          if option
            FallthroughAccessors.apply(attributes, true)
            include_dirty_module(attributes.backend_class, attributes.model_class, *attributes.names)
          end
        end

        private

        def include_dirty_module(backend_class, model_class, *attribute_names)
          dirty_module =
            if Loaded::ActiveRecord && model_class.ancestors.include?(::ActiveModel::Dirty)
              if (model_class < ::ActiveRecord::Base)
                require "mobility/plugins/active_record/dirty"
                Plugins::ActiveRecord::Dirty
              else
                require "mobility/plugins/active_model/dirty"
                Plugins::ActiveModel::Dirty
              end
            elsif Loaded::Sequel && model_class < ::Sequel::Model
              require "mobility/plugins/sequel/dirty"
              Plugins::Sequel::Dirty
            else
              raise ArgumentError, "#{model_class} does not support Dirty module."
            end
          backend_class.include dirty_module
          model_class.include dirty_module.const_get(:MethodsBuilder).new(*attribute_names)
        end
      end
    end
  end
end
