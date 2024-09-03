const { Router } = require("express");
const multer = require("multer");
const path = require("path");
const { Blog } = require("../models/blog"); // Ensure Blog is correctly imported
const { User } = require("../models/user")
const { Comment } = require("../models/comment");
const { log } = require("console");

const storage = multer.diskStorage({
    destination: function (req, file, cb) {
        cb(null, path.resolve(`./public/images/uploads/`));
    },
    filename: function (req, file, cb) {
        const fileName = `${Date.now()}-${file.originalname}`;
        cb(null, fileName);
    }
});

const upload = multer({ storage: storage }); // Corrected the typo here

const router = Router();
router.post("/", upload.single("coverImage"), async (req, res) => {
    console.log(req.body);

    if (!req.file) {
        return res.status(400).json({ success: false, message: "No file uploaded" });
    }

    const { title, body, user_id } = req.body;


    try {
        const user = await User.findById(user_id);
        const blog = await Blog.create({
            title,
            body,
            createdBy: user._id,
            coverImageURL: `/uploads/${req.file.filename}`
        });

        return res.json({ success: true, blog });
    } catch (error) {
        console.error(error);
        return res.status(500).json({ success: false, message: "Failed to create blog" });
    }
});

router.get('/', async (req, res) => {
    try {
        const allBlogs = await Blog.find({})
            .sort({ createdAt: -1 })
            .populate('createdBy', 'fullName');
        return res.json(allBlogs);
    } catch (error) {
        console.error('Error fetching blogs:', error);
        return res.status(500).json({ error: 'Internal server error' });
    }
});

router.get('/user/:createdBy', async (req, res) => {
    try {
        const { createdBy } = req.params;

        const allBlogs = await Blog.find({ createdBy })
            .sort({ createdAt: -1 })
            .populate('createdBy', 'fullName');

        return res.json(allBlogs);
    } catch (error) {
        console.error('Error fetching blogs:', error);
        return res.status(500).json({ error: 'Internal server error' });
    }
});



router.post('/comment/:blogId', async (req, res) => {
    const comment = await Comment.create({
        content: req.body.content,
        blogId: req.params.blogId,
        createdBy: req.body.createdBy,
    })
    return res.json({ comment: comment })
})

router.get("/comment/:id", async (req, res) => {
    const comments = await Comment.find({ blogId: req.params.id })
        .populate({
            path: 'createdBy',
            select: 'fullName' // Select only the fullName field
        }).sort({ createdAt: -1 });
    return res.json(comments);
})

module.exports = router;
