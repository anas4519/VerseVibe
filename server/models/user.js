const { Schema, model } = require("mongoose");
const { createHmac, randomBytes } = require("crypto")
const {createTokenForUser, validateToken} = require("../services/auth")

const userSchema = new Schema({
    fullName: {
        type: String,
        required: true
    },
    email: {
        type: String,
        required: true,
        unique: true
    },
    salt: {
        type: String,
    },
    password: {
        type: String,
        required: true
    },
    profileImageURL: {
        type: String,
    },
    role: {
        type: String,
        enum: ["USER", "ADMIN"],
        default: "USER"
    },

}, { timestamps: true });
userSchema.pre('save', function (next) {
    const user = this;
    if (!user.isModified("password")) return;

    const salt = randomBytes(16).toString();
    const hashedPassword = createHmac("sha256", salt)
        .update(user.password)
        .digest("hex")

    this.salt = salt;
    this.password = hashedPassword;
    next();

})

userSchema.static("matchPasswordAndGenerateToken", async function(email, password) {
    const user = await this.findOne({ email });
    if (!user) throw new Error('User not found!');

    const salt = user.salt;
    const hashedPassword = user.password;
    const userProvidedHash = createHmac("sha256", salt)
        .update(password)
        .digest("hex");

    if (hashedPassword !== userProvidedHash) throw new Error('Incorrect Password!');
    return createTokenForUser(user);
});

router.post("/generateOTPToChangePassword", async (req, res) => {
  try {
    const { email } = req.body;
    const existingUser = await User.findOne({ email });
    if (!existingUser) {
      return res.status(400).json({ status: "User does not exist" });
    }

    const otp = crypto.randomInt(1000, 10000).toString();
    const otpExpiry = Date.now() + 10 * 60 * 1000;

    // Save OTP and expiry in temporary storage (can be stored in DB as well)
    otpStore[email] = { otp, otpExpiry };

    // Send the OTP to the user's email
    const mailOptions = {
      from: "versevibe45@gmail.com",
      to: email,
      subject: "Verify Your Email - OTP",
      text: `Your OTP for resetting password on CardVault is: ${otp}. This OTP is valid for 10 minutes.`,
    };

    transporter.sendMail(mailOptions, (error, info) => {
      if (error) {
        console.error("Error sending email:", error);
        return res.status(500).json({ status: "Failed to send OTP email" });
      } else {
        console.log("OTP email sent: " + info.response);
        return res.json({ status: "OTP sent to email", email });
      }
    });
  } catch (error) {
    console.error("Error while sending OTP:", error);
    return res
      .status(500)
      .json({ status: "An error occurred while sending OTP" });
  }
});

router.post("/verifyOTPToChangePassword", async (req, res) => {
  try {
    const { email, otp } = req.body;
    const storedOtpDetails = otpStore[email];
    if (!storedOtpDetails) {
      return res.status(400).json({ status: "OTP not found or expired" });
    }

    const { otp: storedOtp, otpExpiry } = storedOtpDetails;

    if (storedOtp === otp && Date.now() < otpExpiry) {
      delete otpStore[email];
      return res.json(true);
    } else {
      return res.status(400).json({ status: "Invalid or expired OTP" });
    }
  } catch (error) {
    console.error("Error during OTP verification:", error);
    return res
      .status(500)
      .json({ status: "An error occurred during OTP verification" });
  }
});

router.patch("/resetPassword", async (req, res) => {
    try {
        const {email, password} = req.body;
        const user = await User.findOne({ email });
        user.password = password
        await user.save();
        return res.status(200).json({ status: "Password updated successfully" });
    } catch (error) {
        console.error("Error during password reset:", error);
        return res.status(500).json({ status: "An error occurred during password reset" });
    }
});
const User = model('user', userSchema)
module.exports = {User};