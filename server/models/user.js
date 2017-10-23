const mongoose = require('mongoose');
var User = mongoose.model('Users',{
  _id:{
    type: String,
    require: true,
    minLength: 8,
    trim: true
  },
  password:{
    type: String,
    require: true,
    minLength: 8,
  },
  firstName:{
    type: String,
    minLength: 1,
    trim: true
  },
  lastName:{
    type: String,
    minLength: 1,
    trim: true
  },
  dob:{
    type: Date
  },
  phone:{
    type: Number
  },
  email:{

  },
  address:{
    type: String
  },
  occupation:{
    type: String
  }
});
module.exports = {User};
