App.notifications = App.cable.subscriptions.create("ChatUserChannel", {
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
    if (data.content == "update_location") {
      $('#map_order_message_'+data.order_id).attr('data-latitude-shipper', data.latitude);
      $('#map_order_message_'+data.order_id).attr('data-longitude-shipper', data.longitude);
    } else if (data.content == "order_food_out") {
      Swal.fire({
        title: "Đơn hàng đã được giao thành công!",
        animation: false,
        customClass: {
          popup: 'animated tada'
        },
        type: 'warning',
        allowOutsideClick: false
      }).then((result) => {
        if (result.value) {
          window.location.reload();
        }
      });
    } else {
      var img = '/assets/img/default-avatar.jpg';
      if (data.image != null) {
        img = data.image
      }
      var html = [
        '<div class="chat-message clearfix">',
          '<img width="32" height="32" src="'+img+'" alt="Default avatar">',
          '<div class="chat-message-content clearfix">',
            '<span class="chat-time">' + data.date_time + '</span>',
            '<h5><strong>',
              ''+ data.user_name +'',
            '</strong></h5>',
            '<p>' + data.message + '</p>',
          '</div>',
        '</div>',
        '<hr>'
      ];
      $('#history_live_chat_'+data.order_id).append(html.join(''));
      if (data.receiver && getCookie('chat_order_'+data.order_id) == 1) {
        $('#header_notify_'+data.order_id).addClass('quadrat');
        setCookie('notify_chat_order_'+data.order_id, 1, 365);
        function setCookie(cname, cvalue, exdays) {
          var d = new Date();
          d.setTime(d.getTime() + (exdays*24*60*60*1000));
          var expires = "expires="+ d.toUTCString();
          document.cookie = cname + "=" + cvalue + ";" + expires + ";path=/";
        }
      }
      var objChat = document.getElementById("history_live_chat_"+data.order_id);
      objChat.scrollTop = objChat.scrollHeight;
    }
  }
});
