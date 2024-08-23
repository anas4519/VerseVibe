const express = require("express")
const userRoute = require("./routes/user")
const mongoose = require("mongoose")
const blogsRoute = require("./routes/blog")
const path = require('path');
const app = express();
app.use(express.json())
const PORT = 8000;
mongoose.connect("mongodb://localhost:27017/versevibe").then((e) => console.log("MongoDB connected!")
)
// app.use(express.urlencoded({extended: true}))
app.use(express.static(path.join(__dirname, 'public')));
app.use('/user', userRoute)
app.use('/blogs', blogsRoute)
app.listen(PORT, () => console.log(`Server started at PORT:${PORT}`));