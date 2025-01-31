module Admin
  class DashboardPolicy < ApplicationPolicy
    pre_check :require_admin!

    def show?
      true
    end
  end
end
