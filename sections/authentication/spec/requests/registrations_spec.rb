require 'rails_helper'

RSpec.describe 'Registrations' do
  describe 'GET /registration/new' do
    subject! { get new_registration_path }

    it { expect(response).to have_http_status :ok }
  end

  describe 'POST /registration' do
    subject! { post registration_path, params: params }

    context 'when data are valid' do
      let(:params) { { user: attributes_for(:user) } }

      it { expect(response).to have_http_status :redirect }
      it { expect(response).to redirect_to root_path }
      it { expect(flash[:notice]).to eq I18n.t('registrations.create.notice') }
    end

    context 'when data are invalid' do
      let(:params) { { user: attributes_for(:user).merge(email_address: nil) } }

      it { expect(response).to have_http_status :unprocessable_entity }
    end
  end
end
