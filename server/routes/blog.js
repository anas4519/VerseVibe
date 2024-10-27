const { Router } = require("express");
const multer = require("multer");
const path = require("path");
const { Blog } = require("../models/blog"); // Ensure Blog is correctly imported
const { User } = require("../models/user");
const { Comment } = require("../models/comment");
const { log } = require("console");
const fs = require("fs");
const { CloudinaryStorage } = require("multer-storage-cloudinary");
const cloudinary = require("cloudinary").v2;
require("dotenv").config();

cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
  api_key: process.env.CLOUDINARY_API_KEY,
  api_secret: process.env.CLOUDINARY_API_SECRET,
});

// Set up Cloudinary storage
const storage = new CloudinaryStorage({
  cloudinary: cloudinary,
  params: {
    folder: "uploads", // Cloudinary folder for cover images
    format: async (req, file) => "png", // Optional: specify the format
    public_id: (req, file) => Date.now() + "-" + file.originalname,
  },
});

const upload = multer({ storage: storage });

const router = Router();
router.post("/", upload.single("coverImage"), async (req, res) => {
  if (!req.file) {
    return res
      .status(400)
      .json({ success: false, message: "No file uploaded" });
  }

  const { title, body, user_id } = req.body;

  try {
    const user = await User.findById(user_id);
    const blog = await Blog.create({
      title,
      body,
      createdBy: user._id,
      coverImageURL: req.file.path, // Cloudinary URL
    });

    return res.json({ success: true, blog });
  } catch (error) {
    console.error("Error creating blog:", error);
    return res
      .status(500)
      .json({ success: false, message: "Failed to create blog" });
  }
});

router.get("/", async (req, res) => {
  try {
    const allBlogs = await Blog.find({})
      .sort({ createdAt: -1 })
      .populate("createdBy", "fullName profileImageURL");
    return res.json(allBlogs);
  } catch (error) {
    console.error("Error fetching blogs:", error);
    return res.status(500).json({ error: "Internal server error" });
  }
});

router.get("/user/:createdBy", async (req, res) => {
  try {
    const { createdBy } = req.params;

    const allBlogs = await Blog.find({ createdBy })
      .sort({ createdAt: -1 })
      .populate("createdBy", "fullName profileImageURL");

    return res.json(allBlogs);
  } catch (error) {
    console.error("Error fetching blogs:", error);
    return res.status(500).json({ error: "Internal server error" });
  }
});

router.post("/comment/:blogId", async (req, res) => {
  const comment = await Comment.create({
    content: req.body.content,
    blogId: req.params.blogId,
    createdBy: req.body.createdBy,
  });
  return res.json({ comment: comment });
});

router.get("/comment/:id", async (req, res) => {
  try {
    const comments = await Comment.find({ blogId: req.params.id })
      .populate({
        path: "createdBy",
        select: "fullName profileImageURL",
      })
      .sort({ createdAt: -1 });

    return res.json(comments);
  } catch (error) {
    console.error("Error fetching comments:", error);
    return res.status(500).json({ message: "Server error" });
  }
});

router.delete("/:id", async (req, res) => {
  const { id } = req.params;

  try {
    const blog = await Blog.findById(id);

    if (!blog) {
      return res.status(404).json({ success: false });
    }

    // Delete the cover image from Cloudinary using the public ID
    const coverImagePublicId = blog.coverImageURL
      .split("/")
      .slice(-2)
      .join("/")
      .replace(/\.[^/.]+$/, "");

    if (coverImagePublicId) {
      await cloudinary.uploader.destroy(coverImagePublicId, (error, result) => {
        if (error) {
          console.error("Error deleting image from Cloudinary:", error);
        }
      });
    } else {
      console.log("No cover image found for deletion on Cloudinary.");
    }

    // Delete the blog document from MongoDB
    await Blog.findByIdAndDelete(id);

    return res.json({ success: true });
  } catch (error) {
    console.error("Error deleting blog:", error);
    return res.status(500).json({ success: false });
  }
});

router.patch("/:id", async (req, res) => {
  const { id } = req.params;
  const { title, body } = req.body;

  try {
    const updatedBlog = await Blog.findByIdAndUpdate(
      id,
      { title, body },
      { new: true }
    );

    if (!updatedBlog) {
      return res.status(404).json({ message: "Blog not found" });
    }

    res.json(true);
  } catch (error) {
    res.status(500).json({ message: "Server error", error });
  }
});

router.post("/getBlogsByIds", async (req, res) => {
  try {
    const { ids } = req.body;
    if (!ids || !Array.isArray(ids) || ids.length === 0) {
      return res.status(400).json({ message: "No blog IDs provided." });
    }

    const blogs = await Blog.find({
      _id: { $in: ids },
    }).populate("createdBy", "fullName profileImageURL");

    if (blogs.length === 0) {
      return res.status(404).json({ message: "No blogs found." });
    }

    res.status(200).json(blogs);
  } catch (err) {
    console.error("Error fetching blogs:", err);
    res.status(500).json({ message: "Server error" });
  }
});

module.exports = router;
