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

const Notification = require('../models/Notification');

const sendNotification = async (fcmToken, title, body, data = {}, userId = null) => {
    // 1. Save to Database if userId is provided
    if (userId) {
        try {
            await Notification.create({
                recipient: userId,
                title,
                body,
                data
            });
            console.log(`Notification saved for user ${userId}`);
        } catch (dbError) {
            console.error('Error saving notification to DB:', dbError);
        }
    }

    // 2. Send Push Notification via Firebase
    if (!admin.apps.length) return;

    // Check if token is valid (not empty)
    if (!fcmToken || fcmToken.trim() === '') {
        console.warn(`No FCM token for user ${userId}, skipping push notification.`);
        return;
    }

    const message = {
        notification: { title, body },
        data: { ...data, click_action: 'FLUTTER_NOTIFICATION_CLICK' },
        token: fcmToken
    };

    try {
        const response = await admin.messaging().send(message);
        console.log('Successfully sent push message:', response);
        return response;
    } catch (error) {
        console.error('Error sending push message:', error);
    }
};

module.exports = { sendNotification };
