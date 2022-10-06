const express = require('express');
const app = express();
const cors = require('cors');
const mongoose = require('mongoose');
const bodyParser = require('body-parser');
const http = require('http').Server(app);
const io = require('socket.io')(http);


const dbUrl = "mongodb+srv://chatapp:sZ4xkFfh9gc71l6x@cluster0.szokxbn.mongodb.net/chatdb?retryWrites=true&w=majority";
const PORT = 8000;

app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({extended: false}));
app.use(express.static(__dirname));

app.use(function (req, res, next) {
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', '*');
    res.setHeader('Access-Control-Allow-Headers', '*');
    next();
});

const Message = mongoose.model('Message',{ name : String, message : String});


app.get('/messages', (req, res) => {
    Message.find({},(err, messages)=> {
        res.send(messages);
    });
});

app.post('/messages', (req, res) => {
    let message = new Message(req.body);
    message.save((err) => {
        if(err){
            res.sendStatus(500);
            console.log(err);
        }
        else {
            io.emit('message', req.body);
            res.sendStatus(200);
        }
    });
});

io.on('connection', () =>{
    console.log('a user is connected');
   })


mongoose.connect(dbUrl , (err) => { 
    if(err)
        console.log(err);
    else
        console.log('mongodb connected');
});

const server = http.listen(PORT, () => {
    console.log('Server running on port: ', PORT);
});
