# frozen_string_literal: true

module Services
  module Callable
    extend ActiveSupport::Concern

    included do # rubocop:disable Metrics/BlockLength
      extend ActiveModel::Callbacks
      include ActiveModel::Validations
      include Interactor
      include Memery

      define_model_callbacks :validation

      def call
        if valid?
          result = execute
          context.result ||= result
          return
        end

        context.fail!(
          errors:         errors,
          error_messages: errors.full_messages
        )
      end

      memoize def configuration
        config =
          begin
            Rails.application.config_for(service_name)
          rescue StandardError
            settings.presence || {}
          end

        config.deep_symbolize_keys
      end

      def execute; end

      def method_missing(method, ...)
        context.public_send(method, ...)
      end

      #
      # `context` responds to any method. If the context
      # lacks the key, it returns nil.
      def respond_to_missing?(_method_name, _include_private = false)
        true
      end

      memoize def service_name
        self.class.name.underscore.gsub(/_(request|client|service)\z/i, '')
      end

      def valid?
        run_callbacks :validation do
          super
        end
      end
    end
  end
end
