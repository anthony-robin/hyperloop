module Admin
  class UserPolicy < ApplicationPolicy
    pre_check :admin_up?

    def index?
      true
    end
  end
end
