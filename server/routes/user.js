const { Router } = require("express");
const { User } = require("../models/user");
const { auth } = require("../middlewares/auth");
const { validateToken } = require("../services/auth");
const nodemailer = require("nodemailer");
const crypto = require("crypto");
const multer = require("multer");
const path = require("path");
const cloudinary = require("cloudinary").v2;
const { CloudinaryStorage } = require("multer-storage-cloudinary");

cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
  api_key: process.env.CLOUDINARY_API_KEY,
  api_secret: process.env.CLOUDINARY_API_SECRET,
});

const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: process.env.EMAIL,
    pass: process.env.PASSWORD,
  },
});

const otpStore = {};
const router = Router();

router.post("/signin", async (req, res) => {
  try {
    const { email, password } = req.body;
    const token = await User.matchPasswordAndGenerateToken(email, password);
    const user = await User.findOne({ email });

    return res.json({
      status: "Signed in!",
      token,
      email: email,
      name: user.fullName,
    });
  } catch (error) {
    return res.status(401).json({ error: error.message });
  }
});

router.post("/tokenIsValid", async (req, res) => {
  try {
    const token = req.header("x-auth-token");
    // console.log(token);
    if (!token) return res.json(false);
    const verified = validateToken(token);
    if (!verified) return res.json(false);
    const userId = verified._id;
    const user = await User.findById(userId);

    if (!user) return res.json(false);
    return res.json(true);
  } catch (e) {
    res.status(500).json({ error: "Error" });
  }
});

router.get("/", auth, async (req, res) => {
  const user = await User.findById(req.user);

  res.json({
    token: req.token,
    email: req.user.email,
    name: user.fullName,
    _id: user._id,
    profileImageURL: user.profileImageURL,
  });
});

router.post("/signup", async (req, res) => {
  try {
    const { fullName, email, password } = req.body;

    // Check if the user already exists
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({ status: "User already exists" });
    }

    // Generate a random OTP
    const otp = crypto.randomInt(1000, 10000).toString();
    const otpExpiry = Date.now() + 10 * 60 * 1000;

    // Save OTP and expiry in temporary storage (can be stored in DB as well)
    otpStore[email] = { otp, otpExpiry };

    // Send the OTP to the user's email
    const mailOptions = {
      from: "versevibe45@gmail.com",
      to: email,
      subject: "Verify Your Email - OTP",
      text: `Your OTP for email verification is: ${otp}. This OTP is valid for 10 minutes.`,
    };

    transporter.sendMail(mailOptions, (error, info) => {
      if (error) {
        console.error("Error sending email:", error);
        return res.status(500).json({ status: "Failed to send OTP email" });
      } else {
        return res.json({ status: "OTP sent to email", email });
      }
    });
  } catch (error) {
    console.error("Error during signup:", error);
    return res.status(500).json({ status: "An error occurred during signup" });
  }
});

router.post("/verify-otp", async (req, res) => {
  try {
    const { email, otp, fullName, password } = req.body;

    // Check if OTP is present and not expired
    const storedOtpDetails = otpStore[email];
    if (!storedOtpDetails) {
      return res.status(400).json({ status: "OTP not found or expired" });
    }

    const { otp: storedOtp, otpExpiry } = storedOtpDetails;

    // Check if the OTP matches and is within the expiry time
    if (storedOtp === otp && Date.now() < otpExpiry) {
      // Create the user as OTP is verified
      await User.create({
        fullName,
        email,
        password,
      });

      // Clear OTP from temporary storage after successful verification
      delete otpStore[email];

      return res.json({ status: "Signed Up and Verified" });
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

const storage = new CloudinaryStorage({
  cloudinary: cloudinary,
  params: {
    folder: "profileImages",
    format: async (req, file) => "png", // Choose the format if necessary
    public_id: (req, file) => Date.now() + "-" + file.originalname,
  },
});

const upload = multer({ storage: storage });

router.post(
  "/upload-profile-image/:userId",
  upload.single("profileImage"),
  async (req, res) => {
    try {
      const userId = req.params.userId;
      const file = req.file;
      if (!file) {
        return res.status(400).json({ message: "No file uploaded" });
      }

      const imageUrl = file.path; // URL from Cloudinary
      const user = await User.findByIdAndUpdate(
        userId,
        { profileImageURL: imageUrl },
        { new: true }
      );

      if (!user) {
        return res.status(404).json({ message: "User not found" });
      }
      res
        .status(200)
        .json({ message: "Profile image updated successfully", imageUrl });
    } catch (error) {
      console.error("Error updating profile image:", error);
      res.status(500).json({ message: "Server error", error });
    }
  }
);

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
      text: `Your OTP for resetting password on VerseVibe is: ${otp}. This OTP is valid for 10 minutes.`,
    };

    transporter.sendMail(mailOptions, (error, info) => {
      if (error) {
        console.error("Error sending email:", error);
        return res.status(500).json({ status: "Failed to send OTP email" });
      } else {
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
    const { email, password } = req.body;
    const user = await User.findOne({ email });
    user.password = password;
    await user.save();
    return res.status(200).json({ status: "Password updated successfully" });
  } catch (error) {
    console.error("Error during password reset:", error);
    return res
      .status(500)
      .json({ status: "An error occurred during password reset" });
  }
});

module.exports = router;
