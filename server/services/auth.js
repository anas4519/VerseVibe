const JWT = require("jsonwebtoken")
require("dotenv").config();

const secret = process.env.SECRET;

function createTokenForUser(user) {
    const payload = {
        _id: user._id,
        email: user.email,
        profileImageURL: user.profileImageURL,
        role: user.role
    };
    const token = JWT.sign(payload, secret)
    console.log(token);
    return token;
}

function validateToken(token) {
    const payload = JWT.verify(token, secret)
    return payload;
}

module.exports = {
    createTokenForUser,
    validateToken
}