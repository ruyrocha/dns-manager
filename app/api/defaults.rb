module Defaults
  extend ActiveSupport::Concern

  included do
    version 'v1', using: :path
    default_format :json
    format :json
    formatter :json, Grape::Formatter::ActiveModelSerializers
    add_swagger_documentation info: {
      title: "The API to manage DNS Records with easy.",
      hide_documentation_path: true
    }

    helpers do
      def permitted_params
        @permitted_params ||= declared(
          params,
          include_missing: false
        )
      end

      def logger
        Rails.logger
      end
    end

    rescue_from ::ActiveRecord::RecordNotFound do |e|
      error!({
        error: "#{e.class} error",
        message: e.message
      }, 404)
    end

    rescue_from ::ActiveRecord::RecordInvalid do |e|
      error!({
        error: "#{e.class} error",
        message: e.message
      }, 422)
    end
  end
end
