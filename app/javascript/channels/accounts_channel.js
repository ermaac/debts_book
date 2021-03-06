import CableReady from "cable_ready"
import consumer from "./consumer"

consumer.subscriptions.create("AccountsChannel", {
  connected () {
    this.send({ message: 'Client is live' })
  },

  received(data) {
    console.log("accounts channel:")
    console.log(data)
    if (data.cableReady) CableReady.perform(data.operations)
  }
});
