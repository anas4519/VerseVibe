const jwt = require("jsonwebtoken");
const {validateToken} = require("../services/auth")

const auth = async (req, res, next) =>{
    try {
        const token = req.header("x-auth-token");
        if(!token) return res.status(401).json({msg : "No auth token"});
        const verified = validateToken(token);
        if(!verified) return res.status(401).json({msg : "Token denied"})
        req.user = verified;
        req.token = token;
        next();
    } catch (err){
        res.status(500).json({msg : `${err}`});
    }
}

module.exports = {auth};