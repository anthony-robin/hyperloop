module Admin
  class DashboardPolicy < ApplicationPolicy
    pre_check :admin_up?

    def show?
      true
    end
  end
end
