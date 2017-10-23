var mongoose = require('mongoose');

var events = mongoose.model('Events',{
  eventName:{
    type: String
  },
  eventDate:{
    type: Date
  },
  creationDate:{
    type: Date
  },
  startTime:{
    type: String
  },
  endTime:{
    type: String
  },
  venue:{
    type: String
  },
  organizer:{
    type: String
  },
  attendees:[{
    userid:{
      type: String
    },
    numOfGuests:{
      type: Number
    },
    accepted:{
      type: Boolean
    }
  }],
  completed:{
    type: Boolean
  }
});
module.exports = {events};
