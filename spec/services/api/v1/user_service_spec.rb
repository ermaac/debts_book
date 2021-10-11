require 'rails_helper'

describe Api::V1::UserService do
  describe '#find_or_create_user!' do
    subject(:find_or_create_user) { described_class.new(email).find_or_create_user! }

    context 'with invalid params' do
      shared_examples 'invalid record' do
        it 'raises error' do
          expect { find_or_create_user }.to raise_error(ActiveRecord::RecordInvalid)
        end
      end

      context 'when email is blank' do
        let(:email) { nil }
        include_examples 'invalid record'
      end

      context 'when email has wrong format' do
        let(:email) { 'not_an_email' }
        include_examples 'invalid record'
      end
    end

    context 'with valid params' do
      let(:email) { 'someone@gmail.com' }

      context 'when user doesn\'t exist' do
        it { is_expected.to be_a(User) }

        it 'creates user' do
          expect { find_or_create_user }.to change { User.count }.by(1).and(change { Account.count }.by(1))

          user = User.find_by(email: email)
          expect(user).to be_present
          expect(user.account).to be_present
        end
      end

      context 'when user exists' do
        let!(:user) { create(:user, email: email) }

        it { is_expected.to be_a(User) }

        it 'doesn\'t create new user' do
          expect { find_or_create_user }.to change { User.count }.by(0).and(not_change { Account.count })
        end
      end
    end
  end
end
