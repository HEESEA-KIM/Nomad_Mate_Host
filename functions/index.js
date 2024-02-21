const functions = require("firebase-functions");
const admin = require("firebase-admin");
const serviceAccount = require("./nomadmate-firebase-adminsdk-wlnhp-2b44d99545.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

exports.sendReservationNotification = functions.firestore
    .document("reservations/{reservationId}")
    .onCreate((snapshot, context) => { // 화살표 함수 매개변수에 괄호 추가
        const reservationData = snapshot.data();

        const payload = {
            notification: {
                title: "새로운 예약이 접수되었습니다.",
                body: `${reservationData.name}님의 예약을 확인 후 승인 해 주세요.`,
                // 여기에 추가 옵션을 포함할 수 있습니다.
            },
        };

        // 특정 토큰이나 주제를 구독한 사용자에게 알림을 보냅니다.
        // 예시: admin.messaging().sendToTopic("reservations", payload);
        // 개별 토큰 사용 시: admin.messaging().sendToDevice(token, payload);

        return admin.messaging().sendToTopic("reservations", payload)
            .then((response) => {
                console.log("Successfully sent message:", response);
            })
            .catch((error) => {
                console.log("Error sending message:", error);
            });
    });
