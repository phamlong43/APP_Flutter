const SockJS = require('sockjs-client');
const Stomp = require('stompjs');

function connectUser(username, token, otherUser) {
    const socket = new SockJS('http://localhost:8080/ws');
    const stompClient = Stomp.over(socket);
    
    // Thêm header debug
    stompClient.debug = function(str) {
        console.log(`[${username} DEBUG] ${str}`);
    };

    console.log(`Connecting ${username} to chat with ${otherUser}`);

    stompClient.connect({ Authorization: `Bearer ${token}` }, (frame) => {
        console.log(`${username} connected:`, frame);

        // Subscribe vào topic cá nhân để nhận tin nhắn
        const subscription = stompClient.subscribe(`/user/${username}/queue/messages`, (message) => {
            console.log(`${username} received:`, JSON.parse(message.body));
        }, (error) => {
            console.error(`${username} subscription error:`, error);
        });

        console.log(`${username} subscribed to /user/${username}/queue/messages`);

        // Gửi tin nhắn thử nghiệm
        setTimeout(() => {
            console.log(`${username} sending message to ${otherUser}...`);
            stompClient.send(`/app/chat.send`, {}, JSON.stringify({
                sender: username,
                receiver: otherUser,
                content: `Xin chào, đây là tin nhắn từ ${username}!`,
                sentAt: new Date().toISOString()
            }));
            console.log(`${username} sent message successfully`);
        }, username === 'user1' ? 2000 : 4000); // user1 gửi sau 2s, user2 gửi sau 4s
    }, (error) => {
        console.error(`${username} connection error:`, error);
    });

    return stompClient;
}

// JWT tokens - Lưu ý: Có thể cần refresh nếu đã hết hạn
const user1Token = 'eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJ1c2VyMSIsInJvbGUiOiJVU0VSIiwiaWF0IjoxNzUxNDI5OTUyLCJleHAiOjE3NTE1MTYzNTJ9.CIMak7y0u5TtHyiFu_C6SdVd_kKAMPvEh7iq3HNXj6jJZkdMuh7-UH8lmIMBenfdI179mWDkhIAMQzT6VRGbcw';
const user2Token = 'eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJ1c2VyMiIsInJvbGUiOiJVU0VSIiwiaWF0IjoxNzUxNDI5OTY1LCJleHAiOjE3NTE1MTYzNjV9.yp3CSkZT0Tl_KISktVR3EtByjrAw1h8AhATKObPohKL-FfV9tomowwSWmI91xZcPB-PS7vWmKBCJamhWkDOCcQ';

console.log('Starting WebSocket chat test...');

const client1 = connectUser('user1', user1Token, 'user2');
const client2 = connectUser('user2', user2Token, 'user1');

// Kiểm tra lịch sử chat sau khi gửi tin nhắn
setTimeout(async () => {
    try {
        console.log('\nFetching chat history between user1 and user2...');
        
        const response = await fetch('http://localhost:8080/api/chat/history?user1=user1&user2=user2', {
            headers: {
                'Authorization': `Bearer ${user1Token}`,
                'Accept': 'application/json'
            }
        });
        
        if (response.ok) {
            const messages = await response.json();
            console.log('Chat history:');
            messages.forEach(msg => {
                console.log(`${msg.sender} -> ${msg.receiver}: ${msg.content} (${msg.sentAt})`);
            });
        } else {
            console.error('Failed to fetch chat history:', response.statusText);
        }
    } catch (error) {
        console.error('Error fetching chat history:', error);
    }
}, 6000);

// Giữ chương trình chạy trong 15 giây
console.log('Test running. Will exit in 15 seconds...');
setTimeout(() => {
    console.log('Test complete. Disconnecting...');
    client1.disconnect();
    client2.disconnect();
    console.log('Disconnected. Exiting.');
    process.exit(0);
}, 15000);
