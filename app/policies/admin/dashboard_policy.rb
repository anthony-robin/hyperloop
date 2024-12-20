module Admin
  class DashboardPolicy < ApplicationPolicy
    pre_check :allow_admins

    def show?
      true
    end
  end
end
