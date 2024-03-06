const functions = require("firebase-functions");
const admin = require("firebase-admin");
const nodemailer = require("nodemailer");
const serviceAccount = require("./nomadmate-firebase-adminsdk-wlnhp-2b44d99545.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

// Naver 이메일 계정을 사용하기 위한 nodemailer 설정
const mailTransport = nodemailer.createTransport({
  host: "smtp.naver.com", // Naver SMTP 서버
  port: 587, // SSL을 사용하는 포트 번호
  secure: false, // SSL 사용
  auth: {
    user: functions.config().nodemailer.email, // Naver 이메일 주소
    pass: functions.config().nodemailer.password, // Naver 비밀번호
  },
});

// Firestore 문서 생성 시 푸시 알림을 보내는 함수
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
      const subscriptionCode = reservationData.subscriptionCode;
      return admin.messaging().sendToTopic(`subscriptionCode_${subscriptionCode}`, payload)
          .then((response) => {
              console.log("Successfully sent message:", response);
              return null;
          })
          .catch((error) => {
              console.log("Error sending message:", error);
              return null;
          });
  });

// "승인" 버튼 클릭 시 이메일을 보내는 함수
exports.sendApprovalEmail = functions.https.onRequest(async (req, res) => {
  if (req.method !== "POST") {
    res.status(405).send("Method Not Allowed");
    return;
  }
  const {to, subject, body} = req.body;
  const mailOptions = {
    from: `Nomad Mate <${functions.config().nodemailer.email}>`,
    to,
    subject,
    text: body,
    html: `<p>${body}</p>`,
  };
  try {
    await mailTransport.sendMail(mailOptions);
    console.log("Successfully sent email");
    res.status(200).send("Email sent");
  } catch (error) {
    console.error("Error sending email:", error);
    res.status(500).send("Failed to send email");
  }
});
