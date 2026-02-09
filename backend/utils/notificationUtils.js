const admin = require('firebase-admin');
const path = require('path');
const fs = require('fs');

const serviceAccountPath = path.join(__dirname, '../firebase-service-account.json');

if (fs.existsSync(serviceAccountPath)) {
    admin.initializeApp({
        credential: admin.credential.cert(serviceAccountPath)
    });
    console.log('Firebase Admin initialized');
} else {
    console.warn('Firebase Service Account file NOT found at:', serviceAccountPath);
    console.warn('Push notifications will NOT be sent.');
}

const sendNotification = async (fcmToken, title, body, data = {}) => {
    if (!admin.apps.length) return;

    const message = {
        notification: { title, body },
        data: { ...data, click_action: 'FLUTTER_NOTIFICATION_CLICK' },
        token: fcmToken
    };

    try {
        const response = await admin.messaging().send(message);
        console.log('Successfully sent message:', response);
        return response;
    } catch (error) {
        console.error('Error sending message:', error);
    }
};

module.exports = { sendNotification };
