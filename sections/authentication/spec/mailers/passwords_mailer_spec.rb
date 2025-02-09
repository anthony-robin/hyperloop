require 'rails_helper'

RSpec.describe PasswordsMailer do
  describe '.reset' do
    subject(:mail) { described_class.reset(user) }

    let(:user) { create :user }

    it 'renders the headers', :aggregate_failures do
      expect(mail.to).to eq [user.email_address]
      expect(mail.from).to eq ['from@example.com']
      expect(mail.subject).to eq I18n.t('passwords_mailer.reset.subject')
    end

    it 'renders the body', :aggregate_failures do
      freeze_time do
        expect(mail.body.encoded).to match('You can reset your password within the next 15 minutes on this password reset page:')
        expect(mail.body.encoded).to match(edit_password_url(user.password_reset_token))
      end
    end
  end
end
