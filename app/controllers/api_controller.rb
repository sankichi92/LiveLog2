class APIController < ActionController::API
  include JWTAuthentication
  include RavenContext

  before_action :set_api_raven_context

  private

  def set_api_raven_context
    Raven.tags_context(client_id: current_client.id) if current_client
  end
end
