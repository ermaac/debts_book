require 'rails_helper'

describe Api::V1::UserService do
  describe '#find_or_create_user' do
    let(:email) { 'someone@gmail.com' }
    subject(:find_or_create_user) { described_class.new(email).find_or_create_user }

    context 'when user doesn\'t exist' do
      it 'creates user' do
        expect { find_or_create_user }.to change { User.count }.by(1).and(change { Account.count }.by(1))

        user = User.find_by(email: email)
        expect(user).to be_present
        expect(user.account).to be_present
      end
    end

    context 'when user exists' do
      let!(:user) { create(:user, email: email) }
      it 'returns existing user' do
        expect { find_or_create_user }.to change { User.count }.by(0).and(change { Account.count }.by(0))
      end
    end
  end
end
