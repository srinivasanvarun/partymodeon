var express = require('express');
var bodyParser = require('body-parser');
var {SHA256} = require('crypto-js');
var {mongoose} = require('./db/mongoose');
var {User} = require('./models/user');
var {events} = require('./models/events');
var {Message} = require('./models/message');

var app = express();
app.use(bodyParser.json());
app.post('/newuser', (req, res) => {
  var newUser = new User({
    _id: req.body.userid,
    password: SHA256(req.body.password + "partymodeon").toString(),
    firstName: req.body.firstName,
    lastName: req.body.lastName,
    dob: req.body.dob,
    phone: req.body.phone,
    address: req.body.address,
    occupation: req.body.occupation
  });
  newUser.save().then(()=>{
    res.status(200).send({"message": "Registration Successful!"});
  },(err)=>{
    res.status(400).send({"message": "Unable to save user data"});
  });
});
app.get('/users', (req, res) => {
  var query = User.find({},'_id firstName lastName');
  query.exec((err,doc) => {
    if(!err){
      res.send(doc);
    }else{
      res.send(err);
    }
  });
});
app.post('/checkuser',(req,res) => {
  User.findById({
    _id: req.body.userid
  }).then((doc)=>{
    if(!doc){
      res.send({"message":"User not found"});
    }
    if(doc.password === SHA256(req.body.password + "partymodeon").toString()){
      res.send({"message":"Successful"});
    }else{
      res.send({"message":"Incorrect user ID or password"});
    }
  });
});
app.post('/newevent',(req,res) => {
  var newEvent = new events({
    eventName: req.body.name,
    eventDate: req.body.date,
    creationDate: new Date().toString(),
    startTime: req.body.startTime,
    endTime: req.body.endTime,
    venue: req.body.venue,
    organizer: req.body.userid
  });
  for (var i = 0; i < req.body.attendees.length; i++) {
    newEvent.attendees.push({userid:req.body.attendees[i],numOfGuests:0,accepted:false});
  }
  newEvent.save().then(() => {
    res.status(200).send({"message":"Event created successfully!"});
  },(err)=>{
    res.status(400).send({"message":"Something's not right! Failed to save."});
  });
});
app.post('/eventaccept',(req,res) => {
  events.findOneAndUpdate(
    {'attendees.userid':req.body.attendees.userid},
    {'$set':{
      'attendees.$.numOfGuests':req.body.attendees.numOfGuests,
      'attendees.$.accepted':true
    }},(err,doc) => {
      if(!err){
        res.status(200).send({"message":"Event successfully accepted"});
      }else{
      res.status(400).send({"message":"Something's not right! Failed to save."});
    }});
});
app.post('/createmessage',(req,res) => {
  Message.findOne(
    {'eventName':req.body.name,
     'eventOrganizer':req.body.organizer},
    (err,doc) => {
      if(doc != null){
        console.log(doc);
        doc.messages.push({content:req.body.message,
          time: new Date().toString(),
          sender:req.body.sender});
        doc.save().then(() => {
            res.send({"message":"Message sent successfully!"});
          },(err)=> {
            res.send({"message":"Message not sent. Try again later"});
          });
      }else{
        var msg = new Message(
          {'eventName':req.body.name,
           'eventOrganizer':req.body.organizer,
          });
          msg.messages.push(
            {content:req.body.message,
             time: new Date().toString(),
             sender:req.body.sender});
          msg.save().then(() => {
            res.send({"message":"Message sent successfully!"});
          },(err)=> {
            res.send({"message":"Message not sent. Try again later"});
          });
      }
    });
});
app.post('/messages',(req,res) => {
  Message.findOne(
    {'eventName':req.body.name,
     'eventOrganizer':req.body.organizer},
    (err,doc) => {
      if(doc != null){
        res.send(doc.messages);
      }else{
        res.send({"message":"No messages found!"});
      }
    });
});
app.listen(3000,()=>{
  console.log('Express listening on 3000 port');
});

module.exports={app};
