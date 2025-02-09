require 'rails_helper'

RSpec.describe 'Passwords' do
  describe 'GET /passwords/new' do
    subject! { get new_password_path }

    it { expect(response).to have_http_status :ok }
  end

  describe 'POST /passwords' do
    subject(:action) { post passwords_path, params: params }

    context 'when email is valid' do
      let!(:user) { create :user }
      let(:params) { { email_address: user.email_address } }

      it { expect { action }.to have_enqueued_mail(PasswordsMailer, :reset).with(user) }

      describe 'response' do
        before { action }

        it { expect(response).to have_http_status :redirect }
        it { expect(response).to redirect_to new_session_path }
        it { expect(flash[:notice]).to eq I18n.t('passwords.create.notice') }
      end
    end

    context 'when email is not found' do
      let(:params) { { email_address: 'fake@email.test' } }

      it { expect { action }.to_not have_enqueued_mail(PasswordsMailer, :reset) }

      describe 'response' do
        before { action }

        it { expect(response).to have_http_status :redirect }
        it { expect(response).to redirect_to new_session_path }
        it { expect(flash[:notice]).to eq I18n.t('passwords.create.notice') }
      end
    end
  end

  describe 'GET /passwords/:token/edit' do
    subject! { get edit_password_path(token) }

    context 'when token is valid' do
      let(:token) { user.password_reset_token }
      let(:user) { create :user }

      it { expect(response).to have_http_status :ok }
    end

    context 'when token is invalid' do
      let(:token) { 'fake' }

      it { expect(response).to have_http_status :redirect }
      it { expect(response).to redirect_to new_password_path }
      it { expect(flash[:alert]).to eq I18n.t('passwords.edit.alert_invalid') }
    end
  end

  describe 'PATCH /passwords/:token' do
    subject! { patch password_path(token), params: params }

    let(:params) { { password: 'newpassword', password_confirmation: 'newpassword' } }

    context 'when token is valid' do
      let(:token) { user.password_reset_token }
      let(:user) { create :user }

      context 'when password params are valid' do
        it { expect(response).to have_http_status :redirect }
        it { expect(response).to redirect_to new_session_path }
        it { expect(flash[:notice]).to eq I18n.t('passwords.update.notice') }
      end

      context 'when password params are invalid' do
        let(:params) { { password: 'foo', password_confirmation: 'bar' } }

        it { expect(response).to have_http_status :redirect }
        it { expect(response).to redirect_to edit_password_path(token) }
        it { expect(flash[:alert]).to eq I18n.t('passwords.update.alert') }
      end
    end

    context 'when token is invalid' do
      let(:token) { 'fake' }

      it { expect(response).to have_http_status :redirect }
      it { expect(response).to redirect_to new_password_path }
      it { expect(flash[:alert]).to eq I18n.t('passwords.edit.alert_invalid') }
    end
  end
end
