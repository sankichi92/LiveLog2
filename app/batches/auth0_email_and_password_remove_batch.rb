class Auth0EmailAndPasswordRemoveBatch < ApplicationBatch
  def run
    User.where.not(password_digest: nil, email: nil).find_each(batch_size: 100) do |user|
      begin
        Auth0User.fetch!(user.id, fields: 'user_id')
        user.update!(email: nil, password_digest: nil)
        logger.info "Removed email and password from user: #{user.id}"
      rescue Auth0::NotFound
        # do nothing
      end

      sleep 0.5
    end
  end
end
