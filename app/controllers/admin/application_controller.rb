module Admin
  class ApplicationController < ApplicationController
    before_action :require_login

    layout 'admin'
  end
end
