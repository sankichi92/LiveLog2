class OpenIDConfig
  attr_reader :domain

  delegate :[], :fetch, to: :config

  def initialize(domain = Rails.application.config.x.auth0.domain)
    @domain = domain
  end

  def config
    @config ||= get_config!
  end

  def get_config!
    @config = get!("https://#{domain}/.well-known/openid-configuration")
  end

  def get_jwks!
    get!(config.fetch(:jwks_uri))
  end

  private

  def get!(endpoint)
    uri = URI.parse(endpoint)
    response = Net::HTTP.get_response(uri)
    JSON.parse(response.body, symbolize_names: true)
  end
end
