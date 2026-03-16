const express = require('express');
const { body, param, query, validationResult } = require('express-validator');
const Task = require('../models/Task');
const User = require('../models/User');
const { authMiddleware, roleMiddleware } = require('../middleware/auth');

const router = express.Router();

// GET /api/tasks â€” Get all tasks (with optional filters)
router.get('/', authMiddleware, async (req, res) => {
  try {
    const { status, from, to } = req.query;
    const filter = {};

    if (req.user.role === 'sales') {
      filter.assignedTo = req.user._id;
    }

    if (status && status !== 'All') {
      filter.status = status;
    }

    if (from || to) {
      filter.createdAt = {};
      if (from) filter.createdAt.$gte = new Date(from);
      if (to) filter.createdAt.$lte = new Date(to);
    }

    const tasks = await Task.find(filter)
      .populate('createdBy', 'name email')
      .populate('assignedTo', 'name email role isActive')
      .sort({ createdAt: -1 });

    res.json({
      success: true,
      data: tasks,
      message: 'Tasks retrieved successfully',
    });
  } catch (error) {
    console.error('Get tasks error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

// GET /api/tasks/:id â€” Get single task with full activity log
router.get('/:id', authMiddleware, async (req, res) => {
  try {
    const task = await Task.findById(req.params.id)
      .populate('createdBy', 'name email')
      .populate('assignedTo', 'name email role isActive')
      .populate('activityLog.changedBy', 'name email');

    if (!task) {
      return res.status(404).json({
        success: false,
        message: 'Task not found',
      });
    }

    if (
      req.user.role === 'sales' &&
      task.assignedTo &&
      task.assignedTo._id.toString() !== req.user._id.toString()
    ) {
      return res.status(403).json({
        success: false,
        message: 'Access denied for this task',
      });
    }

    res.json({
      success: true,
      data: task,
      message: 'Task retrieved successfully',
    });
  } catch (error) {
    console.error('Get task error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

// POST /api/tasks â€” Create task [Manager only]
router.post(
  '/',
  authMiddleware,
  roleMiddleware('manager'),
  [
    body('title').notEmpty().withMessage('Title is required'),
    body('description').notEmpty().withMessage('Description is required'),
    body('location').notEmpty().withMessage('Location is required'),
    body('contactName').notEmpty().withMessage('Contact name is required'),
    body('contactPhone').notEmpty().withMessage('Contact phone is required'),
    body('assignedTo').isMongoId().withMessage('Valid assignee is required'),
    body('deadlineAt').isISO8601().withMessage('Valid deadline is required'),
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

      const {
        title,
        description,
        location,
        contactName,
        contactPhone,
        assignedTo,
        deadlineAt,
      } = req.body;

      const assignee = await User.findOne({
        _id: assignedTo,
        role: 'sales',
        isActive: true,
      }).select('_id name');

      if (!assignee) {
        return res.status(400).json({
          success: false,
          message: 'Assignee must be an active sales user',
        });
      }

      const task = await Task.create({
        title,
        description,
        location,
        contactName,
        contactPhone,
        status: 'Pending',
        assignedTo,
        deadlineAt: new Date(deadlineAt),
        paymentReceived: null,
        paymentMarkedAt: null,
        createdBy: req.user._id,
        activityLog: [
          {
            changedBy: req.user._id,
            changedByName: req.user.name,
            fromStatus: 'Created',
            toStatus: 'Pending',
            timestamp: new Date(),
            note: `Task created and assigned to ${assignee.name}`,
          },
        ],
      });

      const populatedTask = await Task.findById(task._id)
        .populate('createdBy', 'name email')
        .populate('assignedTo', 'name email role isActive');

      res.status(201).json({
        success: true,
        data: populatedTask,
        message: 'Task created successfully',
      });
    } catch (error) {
      console.error('Create task error:', error);
      res.status(500).json({
        success: false,
        message: 'Server error',
      });
    }
  }
);

// PUT /api/tasks/:id â€” Edit task details [Manager only]
router.put(
  '/:id',
  authMiddleware,
  roleMiddleware('manager'),
  [
    body('title').notEmpty().withMessage('Title is required'),
    body('description').notEmpty().withMessage('Description is required'),
    body('location').notEmpty().withMessage('Location is required'),
    body('contactName').notEmpty().withMessage('Contact name is required'),
    body('contactPhone').notEmpty().withMessage('Contact phone is required'),
    body('assignedTo').isMongoId().withMessage('Valid assignee is required'),
    body('deadlineAt').isISO8601().withMessage('Valid deadline is required'),
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

      const task = await Task.findById(req.params.id);
      if (!task) {
        return res.status(404).json({
          success: false,
          message: 'Task not found',
        });
      }

      const {
        title,
        description,
        location,
        contactName,
        contactPhone,
        assignedTo,
        deadlineAt,
      } = req.body;

      const assignee = await User.findOne({
        _id: assignedTo,
        role: 'sales',
        isActive: true,
      }).select('_id name');

      if (!assignee) {
        return res.status(400).json({
          success: false,
          message: 'Assignee must be an active sales user',
        });
      }

      task.title = title;
      task.description = description;
      task.location = location;
      task.contactName = contactName;
      task.contactPhone = contactPhone;
      task.assignedTo = assignedTo;
      task.deadlineAt = new Date(deadlineAt);

      await task.save();

      const updatedTask = await Task.findById(task._id)
        .populate('createdBy', 'name email')
        .populate('assignedTo', 'name email role isActive');

      res.json({
        success: true,
        data: updatedTask,
        message: 'Task updated successfully',
      });
    } catch (error) {
      console.error('Update task error:', error);
      res.status(500).json({
        success: false,
        message: 'Server error',
      });
    }
  }
);

// DELETE /api/tasks/:id â€” Delete task [Manager only]
router.delete(
  '/:id',
  authMiddleware,
  roleMiddleware('manager'),
  async (req, res) => {
    try {
      const task = await Task.findById(req.params.id);
      if (!task) {
        return res.status(404).json({
          success: false,
          message: 'Task not found',
        });
      }

      await Task.findByIdAndDelete(req.params.id);

      res.json({
        success: true,
        data: null,
        message: 'Task deleted successfully',
      });
    } catch (error) {
      console.error('Delete task error:', error);
      res.status(500).json({
        success: false,
        message: 'Server error',
      });
    }
  }
);

// PATCH /api/tasks/:id/status â€” Change task status [Sales or Manager]
router.patch(
  '/:id/status',
  authMiddleware,
  [
    body('newStatus')
      .isIn(['Pending', 'In Progress', 'Completed', 'Cancelled'])
      .withMessage('Invalid status value'),
    body('paymentReceived')
      .optional()
      .custom((value) => typeof value === 'boolean')
      .withMessage('paymentReceived must be true or false'),
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

      const task = await Task.findById(req.params.id);
      if (!task) {
        return res.status(404).json({
          success: false,
          message: 'Task not found',
        });
      }

      if (
        req.user.role === 'sales' &&
        task.assignedTo &&
        task.assignedTo.toString() !== req.user._id.toString()
      ) {
        return res.status(403).json({
          success: false,
          message: 'You can only update your assigned tasks',
        });
      }

      const { newStatus, note, paymentReceived } = req.body;
      const fromStatus = task.status;

      if (fromStatus === newStatus) {
        return res.status(400).json({
          success: false,
          message: 'Task is already in this status',
        });
      }

      if (newStatus === 'Completed' && typeof paymentReceived !== 'boolean') {
        return res.status(400).json({
          success: false,
          message: 'Please specify payment received as yes or no',
        });
      }

      // Add activity log entry
      const paymentNote =
        newStatus === 'Completed'
          ? `Payment received: ${paymentReceived ? 'Yes' : 'No'}`
          : '';
      const combinedNote = [note || '', paymentNote]
        .filter((value) => value && value.trim().length > 0)
        .join(' | ');

      task.activityLog.push({
        changedBy: req.user._id,
        changedByName: req.user.name,
        fromStatus,
        toStatus: newStatus,
        timestamp: new Date(),
        note: combinedNote,
      });

      task.status = newStatus;
      if (newStatus === 'Completed') {
        task.paymentReceived = paymentReceived;
        task.paymentMarkedAt = new Date();
      }
      await task.save();

      const updatedTask = await Task.findById(task._id)
        .populate('createdBy', 'name email')
        .populate('assignedTo', 'name email role isActive')
        .populate('activityLog.changedBy', 'name email');

      res.json({
        success: true,
        data: updatedTask,
        message: `Task status changed from ${fromStatus} to ${newStatus}`,
      });
    } catch (error) {
      console.error('Change status error:', error);
      res.status(500).json({
        success: false,
        message: 'Server error',
      });
    }
  }
);

// PATCH /api/tasks/:id/payment â€” Update payment status for completed task [Sales assignee or Manager]
router.patch(
  '/:id/payment',
  authMiddleware,
  [
    body('paymentReceived')
      .custom((value) => typeof value === 'boolean')
      .withMessage('paymentReceived must be true or false'),
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

      const task = await Task.findById(req.params.id);
      if (!task) {
        return res.status(404).json({
          success: false,
          message: 'Task not found',
        });
      }

      if (
        req.user.role === 'sales' &&
        task.assignedTo &&
        task.assignedTo.toString() !== req.user._id.toString()
      ) {
        return res.status(403).json({
          success: false,
          message: 'You can only update payment for your assigned tasks',
        });
      }

      if (task.status !== 'Completed') {
        return res.status(400).json({
          success: false,
          message: 'Payment status can only be updated after task is completed',
        });
      }

      const { paymentReceived, note } = req.body;
      if (task.paymentReceived === paymentReceived) {
        return res.status(400).json({
          success: false,
          message: `Payment is already marked as ${paymentReceived ? 'received' : 'not received'}`,
        });
      }

      task.paymentReceived = paymentReceived;
      task.paymentMarkedAt = new Date();
      task.activityLog.push({
        changedBy: req.user._id,
        changedByName: req.user.name,
        fromStatus: 'Completed',
        toStatus: 'Completed',
        timestamp: new Date(),
        note:
          note && note.trim().length > 0
            ? note.trim()
            : `Payment status updated: ${paymentReceived ? 'Received' : 'Not received'}`,
      });

      await task.save();

      const updatedTask = await Task.findById(task._id)
        .populate('createdBy', 'name email')
        .populate('assignedTo', 'name email role isActive')
        .populate('activityLog.changedBy', 'name email');

      return res.json({
        success: true,
        data: updatedTask,
        message: `Payment marked as ${paymentReceived ? 'received' : 'not received'}`,
      });
    } catch (error) {
      console.error('Update payment status error:', error);
      return res.status(500).json({
        success: false,
        message: 'Server error',
      });
    }
  }
);

module.exports = router;
