require 'rails_helper'

RSpec.describe 'Sessions' do
  describe 'GET /session/new' do
    subject(:action) { get new_session_path }

    context 'when user is authentified' do
      let(:user) { create :user, :standard }

      before do
        sign_in(user)
        action
      end

      it { expect(response).to have_http_status :redirect }
      it { expect(response).to redirect_to root_path }
    end

    context 'when user is not authentified' do
      before { action }

      it { expect(response).to have_http_status :ok }
    end
  end

  describe 'POST /session' do
    subject! { post session_path, params: params }

    context 'when data are valid' do
      let(:params) { { email_address: user.email_address, password: 'password' } }

      let!(:user) do
        create :user, email_address: 'foobar@demo.test', password: 'password'
      end

      it { expect(response).to have_http_status :redirect }
      it { expect(response).to redirect_to root_path }
    end

    context 'when data are invalid' do
      let(:params) { { email_address: 'fake@email.test', password: 'fake' } }

      it { expect(response).to have_http_status :redirect }
      it { expect(response).to redirect_to new_session_path }
      it { expect(flash[:alert]).to eq I18n.t('sessions.create.alert') }
    end
  end

  describe 'GET /session' do
    subject! { get session_path }

    it { expect(response).to have_http_status :redirect }
    it { expect(response).to redirect_to new_session_path }
  end

  describe 'DELETE /session' do
    subject(:action) { delete session_path }

    before do
      user = create :user
      sign_in(user)

      action
    end

    it { expect(response).to have_http_status :redirect }
    it { expect(response).to redirect_to new_session_path }
  end
end
