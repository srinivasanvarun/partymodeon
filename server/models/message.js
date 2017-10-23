const mongoose = require('mongoose');
var Message = mongoose.model('messages',{
  eventName:{
    type: String,
    require: true
  },
  eventOrganizer:{
    type: String,
    require: true
  },
  messages:[{
    content:{
      type: String
    },
    time:{
      type: Date
    },
    sender:{
      type: String
    }
  }]
});
module.exports = {Message};
