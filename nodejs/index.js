const express = require('express');     //no lugar de //import express from 'express';
const app = express();                  //no lugar de const http = require('http');
    const server = require("http").createServer(app);   
    //const server = http.Server(app);
const socketio = require("socket.io");  //no lugar de //import http from 'http';
//import { Server } from 'socket.io';
//import socketio from 'socket.io';
const path = require('path');           //pro diretorio

const bp = require('body-parser');      //chamado pois o req.body retorna undefined

server.listen(3000, () => { console.log('RODANDO...');  })

//paginas estaticas
app.use(express.static(__dirname + '/public')); //para o public não entender como rota
//app.use(express.static(path.join(__dirname, 'public')));  //pode ser assim tbm
app.use(bp.json());                             //chamado pois o req.body retorna undefined
app.use(bp.urlencoded({ extended: true }));     //chamado pois o req.body retorna undefined
//app.use(path.join(__dirname, '/public'));

//start do servidor socket
const io = socketio(server, {
    allowEIO3: true 
});        
//    allowEIO3: true  permite a conexão pelo delphi
//const io = require("socket.io")(server);
io.on('connect', (socket) => {
    //conexao estabelecida
    //io.to(socket.id).emit('oi','como ssta');
    console.log('CONECTADO.');
    console.log('Cliente conectado ' + socket.id);
    io.to(socket.id).emit({
       status : true,
       message : "Conexão estabelecida com o servidor!"
    });
    
    socket.on('conexao', (res) => {
       console.log(res);
       console.log('Cliente conectado ' + socket.id);
       //io.to(socket.id).emit(res); envia apenas para mim
       socket.broadcast.emit('conexao', res);
    });
    /*
    socket.on('pedido', (res) => {
       console.log(res);
       //io.to(socket.id).emit('pedido', res); //envia apenas para mim
       socket.broadcast.emit('pedido', res);
    });
    */
    app.set("socket", socket);
});

io.on("connection", (socket) => {
    //console.log(socket);
    console.log('Cliente conectado! ' + socket.id);
    console.log('EM CONEXÃO');
    app.set("socket", socket);
});

//ROTAS do sistema -- estaticas
app.get('/', (req, res) => {
    console.log('acessando o index');
    res.render('index.html');
    //res.send('hello');    //retorna como texto
});
app.get('/status', (req, res) => {
    console.log('acessando o status');
    res.send({status:true});
});

app.post('/status', (req, res) => {
    console.log('post status');
    res.send({status:true});
});

//com sockets testes
//----------------------------------------------- funciona assim
const showData = (req, res = response) => {
    const pedido = req.body;      //com data : { ... ele retorna um array com { data{....} }
    console.log('Retorno ' + req.body.usuario + ' ' + req.body.mensagem);   //se quiser o retorno direto
    console.log('Retorno ' + req.body)
    const socket = req.app.get("socket");
    //socket.emit(socket.id, { pedido });
    //socket.emit('pedido', pedido); 
    socket.broadcast.emit('pedido', pedido);
    //res.send(notify);   //aqui exibe o mesmo que entra
    res.send({ status: 'SUCCESS' });
}
module.exports={
    showData
}
app.post('/notifica_pedido', showData);

//----------------------------------------------- funciona assim
app.post('/mensagem', (req, res) => {
    console.log('enviando mensagem');
    const socket = req.app.get("socket");
    socket.broadcast.emit('teste');
    //socket.emit(customerId, { test: "something" });
});
app.post('/message', (req, res) => {
    console.log('Enviando mensagem aos clientes');
    const socket = req.app.get("socket");
    socket.broadcast.emit('message');
    //socket.emit(customerId, { test: "something" });
});

