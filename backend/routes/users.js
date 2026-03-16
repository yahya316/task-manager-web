const express = require('express');
const { body, validationResult } = require('express-validator');
const User = require('../models/User');
const { authMiddleware, roleMiddleware } = require('../middleware/auth');

const router = express.Router();

// GET /api/users — Get all team members [Manager only]
router.get(
  '/',
  authMiddleware,
  roleMiddleware('manager'),
  async (req, res) => {
    try {
      const users = await User.find().select('-password').sort({ createdAt: -1 });

      res.json({
        success: true,
        data: users,
        message: 'Users retrieved successfully',
      });
    } catch (error) {
      console.error('Get users error:', error);
      res.status(500).json({
        success: false,
        message: 'Server error',
      });
    }
  }
);

// POST /api/users — Create new team member [Manager only]
router.post(
  '/',
  authMiddleware,
  roleMiddleware('manager'),
  [
    body('name').notEmpty().withMessage('Name is required'),
    body('email').isEmail().withMessage('Please provide a valid email'),
    body('password')
      .isLength({ min: 6 })
      .withMessage('Password must be at least 6 characters'),
  ],
  async (req, res) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({
          success: false,
          message: errors.array()[0].msg,
        });
      }

      const { name, email, password } = req.body;

      const existingUser = await User.findOne({ email });
      if (existingUser) {
        return res.status(400).json({
          success: false,
          message: 'A user with this email already exists',
        });
      }

      const user = await User.create({
        name,
        email,
        password,
        role: 'sales',
      });

      res.status(201).json({
        success: true,
        data: user.toJSON(),
        message: 'Team member created successfully',
      });
    } catch (error) {
      console.error('Create user error:', error);
      res.status(500).json({
        success: false,
        message: 'Server error',
      });
    }
  }
);

// PATCH /api/users/:id/deactivate — Deactivate member [Manager only]
router.patch(
  '/:id/deactivate',
  authMiddleware,
  roleMiddleware('manager'),
  async (req, res) => {
    try {
      const user = await User.findById(req.params.id);
      if (!user) {
        return res.status(404).json({
          success: false,
          message: 'User not found',
        });
      }

      if (user.role === 'manager') {
        return res.status(400).json({
          success: false,
          message: 'Cannot deactivate a manager account',
        });
      }

      user.isActive = false;
      await user.save();

      res.json({
        success: true,
        data: user.toJSON(),
        message: 'User deactivated successfully',
      });
    } catch (error) {
      console.error('Deactivate user error:', error);
      res.status(500).json({
        success: false,
        message: 'Server error',
      });
    }
  }
);

// PATCH /api/users/:id/activate — Reactivate member [Manager only]
router.patch(
  '/:id/activate',
  authMiddleware,
  roleMiddleware('manager'),
  async (req, res) => {
    try {
      const user = await User.findById(req.params.id);
      if (!user) {
        return res.status(404).json({
          success: false,
          message: 'User not found',
        });
      }

      user.isActive = true;
      await user.save();

      res.json({
        success: true,
        data: user.toJSON(),
        message: 'User activated successfully',
      });
    } catch (error) {
      console.error('Activate user error:', error);
      res.status(500).json({
        success: false,
        message: 'Server error',
      });
    }
  }
);

// DELETE /api/users/:id — Delete member [Manager only]
router.delete(
  '/:id',
  authMiddleware,
  roleMiddleware('manager'),
  async (req, res) => {
    try {
      const user = await User.findById(req.params.id);
      if (!user) {
        return res.status(404).json({
          success: false,
          message: 'User not found',
        });
      }

      if (user.role === 'manager') {
        return res.status(400).json({
          success: false,
          message: 'Cannot delete a manager account',
        });
      }

      await User.findByIdAndDelete(req.params.id);

      res.json({
        success: true,
        data: null,
        message: 'User deleted successfully',
      });
    } catch (error) {
      console.error('Delete user error:', error);
      res.status(500).json({
        success: false,
        message: 'Server error',
      });
    }
  }
);

module.exports = router;
