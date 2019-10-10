App.notifications = App.cable.subscriptions.create("FindShipperChannel", {
  connected: function () {
    console.log("connected");
    // Called when the subscription is ready for use on the server
  },

  disconnected: function () {
    console.log("disconnected");
    // Called when the subscription has been terminated by the server
  },

  received: function (data) {
    // Called when there's incoming data on the websocket for this channel
    sweetalert_find_shipper(data.message, data.order_id, data.status);
  }
});
