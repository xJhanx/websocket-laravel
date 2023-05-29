import './bootstrap';

import Alpine from 'alpinejs';

window.Alpine = Alpine;

Alpine.start();


const channel = Echo.channel("public.playground.1");

//for public channels
channel.subscribed( () => {
    console.log('subscribed');
}).listen('.playground', (e) => {
    console.log(e)
});

const privatechannel = window.Echo.private("private.channel");

//for public channels
privatechannel.subscribed( () => {
    console.log('subscribed2');
}).listen('.private-channel', (e) => {
    console.log(e)
});
