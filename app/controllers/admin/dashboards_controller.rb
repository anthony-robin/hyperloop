module Admin
  class DashboardsController < ApplicationController
    # @route GET /admin/dashboard (admin_dashboard)
    def show
      authorize! with: Admin::DashboardPolicy
    end
  end
end
