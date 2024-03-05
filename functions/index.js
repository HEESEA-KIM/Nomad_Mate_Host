const functions = require("firebase-functions");
const admin = require("firebase-admin");
const serviceAccount = require("./nomadmate-firebase-adminsdk-wlnhp-2b44d99545.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

exports.sendReservationNotification = functions.firestore
    .document("reservations/{reservationId}")
    .onCreate((snapshot, context) => {
        const reservationData = snapshot.data();

        const payload = {
            notification: {
                title: "새로운 예약이 접수되었습니다.",
                body: `${reservationData.name}님의 예약을 확인 후 승인 해 주세요.`,
            },
        };

        // reservationData에서 subscriptionCode를 가져옵니다.
        // 예약 문서에 subscriptionCode 필드가 반드시 존재해야 합니다.
        const subscriptionCode = reservationData.subscriptionCode;

        // subscriptionCode를 사용하여 동적으로 주제를 결정하고 해당 주제에 알림을 발송합니다.
        return admin.messaging().sendToTopic(`subscriptionCode_${subscriptionCode}`, payload)
            .then((response) => {
                console.log("Successfully sent message:", response);
                return null; // Cloud Functions에서는 반드시 Promise 또는 null을 반환해야 합니다.
            })
            .catch((error) => {
                console.log("Error sending message:", error);
                return null;
            });
    });
