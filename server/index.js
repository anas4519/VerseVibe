require("dotenv").config()
const express = require("express")
const userRoute = require("./routes/user")
const mongoose = require("mongoose")
const blogsRoute = require("./routes/blog")
const path = require('path');
const cors = require('cors');
const app = express();
app.use(express.json())
app.use(cors());
const PORT = process.env.PORT || 8000;
mongoose.connect(process.env.MONGO_URL).then((e) => console.log("MongoDB connected!")
)
// app.use(express.urlencoded({extended: true}))
app.use(express.static(path.join(__dirname, 'public')));
app.use('/user', userRoute)
app.use('/blogs', blogsRoute)
app.listen(PORT, () => console.log(`Server started at PORT:${PORT}`));