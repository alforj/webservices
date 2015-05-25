class ApiController < ActionController::Base
  class_attribute :search_params, instance_writer: false
  self.search_params = %i(api_key callback format offset size)

  def self.search_by(*permitted)
    self.search_params |= permitted
  end

  ActionController::Parameters.action_on_unpermitted_parameters = :raise

  rescue_from(ActionController::UnpermittedParameters) do |e|
    render json:   { error:  { unknown_parameters: e.params } },
           status: :bad_request
  end

  rescue_from(Query::InvalidParamsException) do |e|
    render json:   { errors: e.errors },
           status: :bad_request
  end

  respond_to :json, :csv, :tsv

  def search
    s = params.permit(search_params).except(:format)
    s.merge!(api_version: api_version)
    @search = search_class.search_for s
    render
  end

  def not_found
    render json: { error: 'Not Found' }, status: :not_found
  end

  private

  def api_version
    self.class.name.match(/Api::V(\d+)::/) { |m| m[1] }
  end

  def search_class
    parts = self.class.name.gsub(/Controller|Api::V\d+::/, '').split('::')
    parts[0] = parts[0].singularize
    parts.join('::').constantize
  end
end
