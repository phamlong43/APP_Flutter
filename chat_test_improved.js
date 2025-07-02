const SockJS = require('sockjs-client');
const Stomp = require('stompjs');
// Import fetch with modern ES modules syntax for Node.js
const nodeFetch = (...args) => import('node-fetch').then(({default: fetch}) => fetch(...args));

// Hàm gửi tin nhắn qua REST API
async function sendMessage(token, from, to, content) {
    console.log(`Sending message from ${from} to ${to}...`);
    try {
        const response = await nodeFetch('http://localhost:8080/api/messages/send', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': `Bearer ${token}`
            },
            body: JSON.stringify({
                from: from,
                to: to,
                content: content
            })
        });

        if (!response.ok) {
            throw new Error(`HTTP error! Status: ${response.status}`);
        }

        const data = await response.json();
        console.log(`Message sent successfully: ${JSON.stringify(data)}`);
        return data;
    } catch (error) {
        console.error(`Error sending message: ${error.message}`);
        return null;
    }
}

// Hàm lấy lịch sử chat
async function getChatHistory(token, user1, user2) {
    console.log(`Fetching chat history between ${user1} and ${user2}...`);
    try {
        const response = await nodeFetch(`http://localhost:8080/api/chat/history?user1=${user1}&user2=${user2}`, {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': `Bearer ${token}`
            }
        });

        if (!response.ok) {
            throw new Error(`HTTP error! Status: ${response.status}`);
        }

        const data = await response.json();
        console.log(`Retrieved ${data.length} messages between ${user1} and ${user2}`);
        console.log(JSON.stringify(data, null, 2));
        return data;
    } catch (error) {
        console.error(`Error fetching chat history: ${error.message}`);
        return [];
    }
}

function connectUser(userId, token, conversationId) {
    const socket = new SockJS('http://localhost:8080/ws');
    const stompClient = Stomp.over(socket);
    
    // Để xem debug logs
    stompClient.debug = function(str) {
        console.log(`[STOMP DEBUG] ${str}`);
    };

    console.log(`Connecting User ${userId} to conversationId: ${conversationId}`);

    stompClient.connect({ Authorization: `Bearer ${token}` }, (frame) => {
        console.log(`User ${userId} connected:`, frame);

        // Subscribe vào topic
        const subscription = stompClient.subscribe(`/topic/conversation/${conversationId}`, (message) => {
            console.log(`User ${userId} received:`, JSON.parse(message.body));
        }, (error) => {
            console.error(`User ${userId} subscription error:`, error);
        });

        console.log(`User ${userId} subscribed to /topic/conversation/${conversationId}`);

        // Gửi tin nhắn thử nghiệm sau 2 giây
        setTimeout(() => {
            console.log(`User ${userId} sending message...`);
            stompClient.send(`/app/chat/${conversationId}`, {}, JSON.stringify({
                sender: `user${userId}`,
                message: `Xin chào từ User ${userId}`,
                timestamp: new Date().toISOString(),
                attachments: []
            }));
            console.log(`User ${userId} sent message successfully`);
        }, userId * 1000); // user1 gửi sau 1s, user2 gửi sau 2s
    }, (error) => {
        console.error(`User ${userId} connection error:`, error);
    });

    return stompClient;
}

// JWT tokens - Lưu ý: Có thể cần refresh nếu đã hết hạn
const user1Token = 'eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJ1c2VyMSIsInJvbGUiOiJVU0VSIiwiaWF0IjoxNzUxNDI5OTUyLCJleHAiOjE3NTE1MTYzNTJ9.CIMak7y0u5TtHyiFu_C6SdVd_kKAMPvEh7iq3HNXj6jJZkdMuh7-UH8lmIMBenfdI179mWDkhIAMQzT6VRGbcw';
const user2Token = 'eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJ1c2VyMiIsInJvbGUiOiJVU0VSIiwiaWF0IjoxNzUxNDI5OTY1LCJleHAiOjE3NTE1MTYzNjV9.yp3CSkZT0Tl_KISktVR3EtByjrAw1h8AhATKObPohKL-FfV9tomowwSWmI91xZcPB-PS7vWmKBCJamhWkDOCcQ';
const conversationId = 1; // Đúng conversationId từ database

// Hàm kiểm tra việc gửi/nhận tin nhắn
async function testMessageDelivery(senderToken, receiverToken, sender, receiver) {
    console.log(`\n===== TESTING MESSAGE DELIVERY FROM ${sender} TO ${receiver} =====`);
    
    // 1. Lấy số tin nhắn trước khi gửi
    console.log(`Getting initial message count for ${sender} and ${receiver}...`);
    const initialHistory = await getChatHistory(senderToken, sender, receiver);
    const initialCount = initialHistory.length;
    console.log(`Initial message count: ${initialCount}`);
    
    // 2. Gửi tin nhắn với nội dung đặc biệt để dễ nhận biết
    const testContent = `Test message from ${sender} to ${receiver} at ${new Date().toISOString()}`;
    console.log(`Sending test message: "${testContent}"`);
    await sendMessage(senderToken, sender, receiver, testContent);
    
    // 3. Đợi 2 giây để đảm bảo tin nhắn được lưu vào database
    console.log('Waiting 2 seconds for message processing...');
    await new Promise(resolve => setTimeout(resolve, 2000));
    
    // 4. Kiểm tra xem tin nhắn đã được lưu vào database chưa
    console.log('Checking if message was delivered...');
    const updatedHistory = await getChatHistory(receiverToken, sender, receiver);
    
    // 5. Tìm tin nhắn vừa gửi trong lịch sử
    const foundMessage = updatedHistory.find(msg => msg.content === testContent);
    
    if (foundMessage) {
        console.log(`✅ SUCCESS: Message was successfully delivered from ${sender} to ${receiver}`);
        console.log(`Message details: ${JSON.stringify(foundMessage)}`);
        return true;
    } else {
        console.log(`❌ FAILED: Message was NOT delivered from ${sender} to ${receiver}`);
        console.log(`New message count: ${updatedHistory.length} (was ${initialCount})`);
        return false;
    }
}

// Hàm chính để chạy test
async function runTest() {
    console.log('======= PHASE 1: FETCH INITIAL CHAT HISTORY =======');
    // Lấy lịch sử chat trước khi bắt đầu test
    await getChatHistory(user1Token, 'user1', 'user2');
    
    console.log('\n======= PHASE 2: WEBSOCKET CONNECTION TEST =======');
    // Kết nối WebSocket
    const client1 = connectUser(1, user1Token, conversationId);
    const client2 = connectUser(2, user2Token, conversationId);

    // Giữ chương trình chạy trong 8 giây để WebSocket hoạt động và gửi tin nhắn
    console.log('WebSocket test running. Will collect WebSocket messages for 8 seconds...');
    
    return new Promise((resolve) => {
        setTimeout(async () => {
            console.log('\n======= PHASE 3: REST API MESSAGE TEST =======');
            
            // Gửi tin nhắn qua REST API
            console.log('Sending messages via REST API...');
            await sendMessage(user1Token, 'user1', 'user2', 'Tin nhắn từ user1 qua REST API');
            await sendMessage(user2Token, 'user2', 'user1', 'Tin nhắn từ user2 qua REST API');
            
            // Chờ 3 giây cho việc lưu vào database
            console.log('Waiting 3 seconds for messages to be processed...');
            await new Promise(resolve => setTimeout(resolve, 3000));
            
            console.log('\n======= PHASE 4: VERIFY UPDATED CHAT HISTORY =======');
            // Kiểm tra lịch sử chat sau khi đã gửi tin nhắn qua cả WebSocket và REST API
            await getChatHistory(user1Token, 'user1', 'user2');
            
            console.log('\n======= PHASE 5: TEST MESSAGE DELIVERY =======');
            // Kiểm tra việc gửi/nhận tin nhắn giữa hai người dùng
            const test1Result = await testMessageDelivery(user1Token, user2Token, 'user1', 'user2');
            const test2Result = await testMessageDelivery(user2Token, user1Token, 'user2', 'user1');
            
            console.log('\n======= PHASE 6: TESTING SPECIAL MESSAGE CASE =======');
            
            // Gửi tin nhắn theo yêu cầu đặc biệt
            console.log('Testing specific message format "Xin chào!qqq" from user1 to user2...');
            await sendMessage(user1Token, 'user1', 'user2', 'Xin chào!qqq');
            
            // Đợi 2 giây để đảm bảo tin nhắn được xử lý
            console.log('Waiting 2 seconds for special message processing...');
            await new Promise(resolve => setTimeout(resolve, 2000));
            
            // Kiểm tra lịch sử chat để tìm tin nhắn đặc biệt
            console.log('Checking if special message was delivered...');
            const finalHistory = await getChatHistory(user2Token, 'user1', 'user2');
            const specialMessage = finalHistory.find(msg => msg.content === 'Xin chào!qqq');
            
            if (specialMessage) {
                console.log('✅ SUCCESS: Special message "Xin chào!qqq" was delivered successfully');
                console.log(`Message details: ${JSON.stringify(specialMessage)}`);
            } else {
                console.log('❌ FAILED: Special message "Xin chào!qqq" was NOT found in chat history');
            }
            
            console.log('\n======= PHASE 7: TEST SUMMARY =======');
            console.log(`User1 -> User2 message delivery: ${test1Result ? '✅ SUCCESS' : '❌ FAILED'}`);
            console.log(`User2 -> User1 message delivery: ${test2Result ? '✅ SUCCESS' : '❌ FAILED'}`);
            console.log(`Special message "Xin chào!qqq" delivery: ${specialMessage ? '✅ SUCCESS' : '❌ FAILED'}`);
            
            console.log('\n======= TEST COMPLETE =======');
            console.log('Disconnecting WebSocket clients...');
            client1.disconnect();
            client2.disconnect();
            console.log('Disconnected. Exiting.');
            resolve();
        }, 8000);
    });
}

// Chạy test
console.log('Starting comprehensive chat test...');
runTest()
    .then(() => process.exit(0))
    .catch(err => {
        console.error('Test failed with error:', err);
        process.exit(1);
    });
