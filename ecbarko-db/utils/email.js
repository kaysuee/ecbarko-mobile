const nodemailer = require('nodemailer');
require('dotenv').config();  

const transporter = nodemailer.createTransport({
    service: "gmail",
    debug: true,
    port: 587,
    secure: false,
    auth: {
        user: 'ecbarkoportal@gmail.com',
        pass: 'ocfmgagwogsnxyue',
    },
});

const sendOtpEmail = async (email, otp) => {
  const mailOptions = {
    from: process.env.EMAIL_USER,
    to: email,
    subject: 'ECBARKO OTP',
    text: `Your OTP code is: ${otp}`,
  };

  try {
    await transporter.sendMail(mailOptions);
    console.log(`Email sent to ${email}`);
  } catch (error) {
    console.error('Error sending email:', error);
  }
};

const sendResetEmail = async (email, reset) => {
  const mailOptions = {
    from: process.env.EMAIL_USER,
    to: email,
    subject: 'ECBARKO Email Reset',
    text: `Your reset link: ${reset}`,
  };

  try {
    await transporter.sendMail(mailOptions);
    console.log(`Email sent to ${email}`);
  } catch (error) {
    console.error('Error sending email:', error);
  }
};

module.exports = sendOtpEmail;
