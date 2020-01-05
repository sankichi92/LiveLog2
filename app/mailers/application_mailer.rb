class ApplicationMailer < ActionMailer::Base
  DEFAULT_FROM_NAME = 'LiveLog'.freeze
  DEFAULT_FROM_EMAIL = 'noreply@livelog.ku-unplugged.net'.freeze

  layout 'mailer'

  default from: %("#{DEFAULT_FROM_NAME}" <#{DEFAULT_FROM_EMAIL}>)
end
