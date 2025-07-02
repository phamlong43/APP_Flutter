const SockJS = require('sockjs-client');
const Stomp = require('stompjs');

function connectUser(userId, token, conversationId) {
    const socket = new SockJS('http://localhost:8080/ws');
    const stompClient = Stomp.over(socket);

    console.log(`Connecting User ${userId} to conversationId: ${conversationId}`);

    stompClient.connect({ Authorization: `Bearer ${token}` }, (frame) => {
        console.log(`User ${userId} connected:`, frame);

        // Subscribe vào topic
        const subscription = stompClient.subscribe(`/topic/conversation/${conversationId}`, (message) => {
            console.log(`User ${userId} received:`, JSON.parse(message.body));
        }, (error) => {
            console.error(`User ${userId} subscription error:`, error);
        });

        // Gửi tin nhắn thử nghiệm
        setTimeout(() => {
            stompClient.send(`/app/chat/${conversationId}`, {}, JSON.stringify({
                message: `Xin chào từ User ${userId}`,
                attachments: []
            }));
            console.log(`User ${userId} sent message`);
        }, 2000);
    }, (error) => {
        console.error(`User ${userId} connection error:`, error);
    });

    return stompClient;
}

const user1Token = 'eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJ1c2VyMSIsInJvbGUiOiJVU0VSIiwiaWF0IjoxNzUxNDI5OTUyLCJleHAiOjE3NTE1MTYzNTJ9.CIMak7y0u5TtHyiFu_C6SdVd_kKAMPvEh7iq3HNXj6jJZkdMuh7-UH8lmIMBenfdI179mWDkhIAMQzT6VRGbcw';
const user2Token = 'eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJ1c2VyMiIsInJvbGUiOiJVU0VSIiwiaWF0IjoxNzUxNDI5OTY1LCJleHAiOjE3NTE1MTYzNjV9.yp3CSkZT0Tl_KISktVR3EtByjrAw1h8AhATKObPohKL-FfV9tomowwSWmI91xZcPB-PS7vWmKBCJamhWkDOCcQ';
const conversationId = 1; // Đúng conversationId từ database

const client1 = connectUser(1, user1Token, conversationId);
const client2 = connectUser(2, user2Token, conversationId);