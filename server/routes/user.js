const { Router } = require("express")
const { User } = require("../models/user")
const {auth} = require("../middlewares/auth")
const {validateToken} = require("../services/auth")


const router = Router();

router.post("/signin", async (req, res) => {
    try {
        const { email, password } = req.body;
        const token = await User.matchPasswordAndGenerateToken(email, password);
        const user = await User.findOne({ email });
         
        return res.json({ status: 'Signed in!', token , email: email, name: user.fullName});
    } catch (error) {
        console.error("Error during signin: ", error.message);
        return res.status(401).json({ error: error.message });
    }
});
router.post("/signup", async (req, res) => {
    console.log('Request body:', req.body);
    const { fullName, email, password } = req.body;
    await User.create({
        fullName,
        email,
        password
    })
    return res.json({ status: "Signed Up" })
})

router.post("/tokenIsValid", async (req, res)=>{
    try{
        const token = req.header("x-auth-token");
        // console.log(token);
        if(!token) return res.json(false);
        const verified = validateToken(token);
        if(!verified) return res.json(false);
        const userId = verified._id;
        const user = await User.findById(userId);
        
        if(!user) return res.json(false);
        return res.json(true);
    } catch (e){
        res.status(500).json({error: "Error"});
    }
});

router.get('/', auth, async(req, res) =>{

    const user = await User.findById(req.user);
    res.json({user: req.user, token: req.token, email: req.user.email, name: user.fullName, _id: user._id});
})

module.exports = router;