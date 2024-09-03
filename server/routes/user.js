const { Router } = require("express")
const { User } = require("../models/user")
const { auth } = require("../middlewares/auth")
const { validateToken } = require("../services/auth")
const nodemailer = require("nodemailer");
const crypto = require("crypto");
const multer = require("multer");
const path = require("path");

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

        return res.json({ status: 'Signed in!', token, email: email, name: user.fullName });
    } catch (error) {
        console.error("Error during signin: ", error.message);
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
        console.log(user.profileImageURL);


        if (!user) return res.json(false);
        return res.json(true);
    } catch (e) {
        res.status(500).json({ error: "Error" });
    }
});


router.get('/', auth, async (req, res) => {

    const user = await User.findById(req.user);
    

    res.json({token: req.token, email: req.user.email, name: user.fullName, _id: user._id, profileImageURL: user.profileImageURL });
})

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
        const otpExpiry = Date.now() + 10 * 60 * 1000

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
                console.log("OTP email sent: " + info.response);
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
        return res.status(500).json({ status: "An error occurred during OTP verification" });
    }
});



const storage = multer.diskStorage({
    destination: function (req, file, cb) {
        cb(null, path.resolve(`./public/images/profileImages/`));
    },
    filename: function (req, file, cb) {
        const fileName = `${Date.now()}-${file.originalname}`;
        cb(null, fileName);
    }
});
const upload = multer({ storage: storage });

router.post('/upload-profile-image/:userId', upload.single('profileImage'), async (req, res) => {
    try {
        const userId = req.params.userId;
        const file = req.file;
        if (!file) {
            return res.status(400).json({ message: 'No file uploaded' });
        }
        const imageUrl = `/images/profileImages/${file.filename}`;
        const user = await User.findByIdAndUpdate(
            userId,
            { profileImageURL: imageUrl },
            { new: true }
        );
        console.log(user.profileImageURL);

        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }
        res.status(200).json({ message: 'Profile image updated successfully', imageUrl });
    } catch (error) {
        console.error('Error updating profile image:', error);
        res.status(500).json({ message: 'Server error', error });
    }
});




module.exports = router;