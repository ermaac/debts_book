class AccountsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "accounts"
  end

  def receive(data)
    puts data["message"]
    ActionCable.server.broadcast("accounts", "ActionCable is connected")
  end
end
