module Api
  module V1
    class TransferTransactionsController < ApplicationController
      include CableReady::Broadcaster

      skip_before_action :verify_authenticity_token
      before_action :initialize_accounts
      # after_action :broadcast_updates, only: :create

      def create
        TransferService.new(@sender_account, @receiver_account, params[:amount]).transfer
        broadcast_updates
        render json: [@sender_account, @receiver_account]
      end

      private

      def initialize_accounts
        @accounts = params.values_at(:from, :to).map do |email|
          user = UserService.new(email).find_or_create_user
          user.account
        end
        @sender_account, @receiver_account = @accounts
      end

      def broadcast_updates
        remove_outdated_accounts_from_dom
        insert_updated_accounts_into_dom
        cable_ready.broadcast
      end

      def selectors_for_remove
        selectors_for_remove = @accounts
          .map { |account| ".account[data-id=\"#{account.id}\"]" }
          .join(', ')
      end

      def remove_outdated_accounts_from_dom
        cable_ready['accounts'].remove(
          selector: selectors_for_remove,
          select_all: true
        )
      end

      def insert_updated_accounts_into_dom
        cable_ready['accounts'].insert_adjacent_html(
          selector: '#accounts',
          position: 'afterbegin',
          html: render_to_string(collection: @accounts, partial: 'accounts/account')
        )
      end
    end
  end
end
