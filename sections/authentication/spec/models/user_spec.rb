require 'rails_helper'

RSpec.describe User do
  describe '#full_name' do
    subject { user.full_name }

    let(:user) { build :user, first_name: 'John', last_name: 'Doe' }

    it { is_expected.to eq 'John Doe' }
  end
end
