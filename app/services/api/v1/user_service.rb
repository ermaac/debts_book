module Api
  module V1
    class UserService
      attr_reader :email

      def initialize(email)
        @email = email
      end

      def find_or_create_user
        user = find_user
        return user if user.present?

        create_user_with_account
      end

      private

      def find_user
        User.find_by(email: email)
      end

      def create_user_with_account
        user = User.new(email: email)
        user.account = Account.new
        user.tap(&:save!)
      end
    end
  end
end
