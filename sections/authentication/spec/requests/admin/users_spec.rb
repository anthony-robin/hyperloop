require 'rails_helper'

RSpec.describe 'Admin::Users' do
  describe 'GET /admin/users' do
    subject(:action) { get admin_users_path }

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

  describe 'GET /admin/users/new' do
    subject(:action) { get new_admin_user_path }

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

  describe 'POST /admin/users' do
    subject(:action) { post admin_users_path, params: params }

    let(:params) { { user: {} } }

    context 'when user is authentified' do
      before do
        user = create :user, role: role
        sign_in(user)

        action
      end

      context 'when user has ability to access' do
        let(:role) { :admin }

        context 'when params are valid' do
          let(:params) do
            { user: attributes_for(:user).merge(first_name: 'John', last_name: 'Doe') }
          end

          it 'creates a new user', :aggregate_failures do
            created_user = User.last
            expect(created_user.role).to eq 'standard'
            expect(created_user.first_name).to eq 'John'
            expect(created_user.last_name).to eq 'Doe'
          end

          it { expect(response).to have_http_status :redirect }
          it { expect(response).to redirect_to admin_users_path }
          it { expect(flash[:notice]).to eq I18n.t('admin.users.create.notice') }
        end

        context 'when params are invalid' do
          let(:params) do
            { user: attributes_for(:user).merge(first_name: '') }
          end

          it { expect(response).to have_http_status :unprocessable_entity }
        end
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

  describe 'GET /admin/users/:id/edit' do
    subject(:action) { get edit_admin_user_path(user) }

    let(:user) { create :user }

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

  describe 'PATCH /admin/users/:id' do
    subject(:action) { patch admin_user_path(user), params: params }

    let(:user) { create :user }
    let(:params) { { user: {} } }

    context 'when user is authentified' do
      before do
        user = create :user, role: role
        sign_in(user)

        action
      end

      context 'when user has ability to access' do
        let(:role) { :admin }

        context 'when params are valid' do
          let(:params) { { user: { first_name: 'Johnny' } } }

          it { expect(user.reload.first_name).to eq 'Johnny' }
          it { expect(response).to have_http_status :redirect }
          it { expect(response).to redirect_to admin_users_path }
          it { expect(flash[:notice]).to eq I18n.t('admin.users.update.notice') }
        end

        context 'when params are invalid' do
          let(:params) { { user: { first_name: '' } } }

          it { expect(response).to have_http_status :unprocessable_entity }
        end
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

  describe 'DELETE /admin/users/:id' do
    subject(:action) { delete admin_user_path(user) }

    let(:user) { create :user }

    context 'when user is authentified' do
      before do
        user = create :user, role: role
        sign_in(user)

        action
      end

      context 'when user has ability to access' do
        let(:role) { :admin }

        it { expect(response).to have_http_status :redirect }
        it { expect(response).to redirect_to admin_users_path }
        it { expect(flash[:notice]).to eq I18n.t('admin.users.destroy.notice') }
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

  describe 'POST /admin/users/:id/impersonate' do
    subject(:action) { post impersonate_admin_user_path(user) }

    let(:user) { create :user, :standard }

    context 'when user is authentified' do
      before do
        user = create :user, role: role
        sign_in(user)

        action
      end

      context 'when user has ability to impersonate' do
        let(:role) { :admin }

        it { expect(response).to have_http_status :redirect }
        it { expect(response).to redirect_to root_path }
        it { expect(flash[:notice]).to be_nil }
        it { expect(flash[:alert]).to be_nil }
      end

      context 'when user has no ability to impersonate' do
        let(:role) { :admin }
        let(:user) { create :user, :super_admin }

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

  describe 'POST /admin/users/stop_impersonating' do
    subject(:action) { post stop_impersonating_admin_users_path }

    let(:user) { create :user }

    context 'when user is authentified' do
      before do
        user = create :user, role: role
        sign_in(user)

        action
      end

      context 'when user has ability to impersonate' do
        let(:role) { :admin }

        it { expect(response).to have_http_status :redirect }
        it { expect(response).to redirect_to admin_users_path }
      end
    end

    context 'when user is not authentified' do
      before { action }

      it { expect(response).to have_http_status :redirect }
      it { expect(response).to redirect_to new_session_path }
    end
  end
end
