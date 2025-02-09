require 'rails_helper'

RSpec.describe 'Admin::Dashboards' do
  describe 'GET /admin/dashboard' do
    subject(:action) { get admin_dashboard_path }

    context 'when user is authentified' do
      before do
        user = create :user, role: role
        sign_in(user)

        action
      end

      context 'when user has ability to access' do
        let(:role) { :admin }

        it { expect(response).to have_http_status :ok }
      end

      context 'when user does not have ability to access' do
        let(:role) { :standard }

        it { expect(response).to have_http_status :redirect }
        it { expect(response).to redirect_to root_path }
        it { expect(flash[:alert]).to eq I18n.t('action_policy.default') }
      end
    end

    context 'when user is not authentified' do
      before { action }

      it { expect(response).to have_http_status :redirect }
      it { expect(response).to redirect_to new_session_path }
    end
  end
end
