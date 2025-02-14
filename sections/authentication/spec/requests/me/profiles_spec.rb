require 'rails_helper'

RSpec.describe 'Me::Profiles' do
  before do
    user = create :user
    sign_in(user)
  end

  describe 'GET /me/profile/edit' do
    subject! { get edit_me_profile_path }

    it { expect(response).to have_http_status :ok }
  end

  describe 'PATCH /me/profile' do
    subject! { patch me_profile_path, params: params }

    context 'when data are valid' do
      let(:params) { { user: { first_name: 'John' } } }

      it { expect(response).to have_http_status :redirect }
      it { expect(response).to redirect_to edit_me_profile_path }
      it { expect(flash[:notice]).to eq I18n.t('me.profiles.update.notice') }
    end

    context 'when data are invalid' do
      let(:params) { { user: attributes_for(:user).merge(first_name: nil) } }

      it { expect(response).to have_http_status :unprocessable_entity }
    end
  end
end
