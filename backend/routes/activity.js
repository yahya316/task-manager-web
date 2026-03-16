const express = require('express');
const Task = require('../models/Task');
const { authMiddleware, roleMiddleware } = require('../middleware/auth');

const router = express.Router();

// GET /api/activity — Get all recent activity across all tasks [Manager only]
router.get(
  '/',
  authMiddleware,
  roleMiddleware('manager'),
  async (req, res) => {
    try {
      const tasks = await Task.find({
        'activityLog.0': { $exists: true },
      })
        .select('title activityLog')
        .populate('activityLog.changedBy', 'name email');

      // Flatten all activity logs with task title
      const allActivity = [];
      tasks.forEach((task) => {
        task.activityLog.forEach((log) => {
          allActivity.push({
            taskId: task._id,
            taskTitle: task.title,
            changedBy: log.changedBy,
            changedByName: log.changedByName,
            fromStatus: log.fromStatus,
            toStatus: log.toStatus,
            timestamp: log.timestamp,
            note: log.note,
          });
        });
      });

      // Sort by timestamp descending (most recent first)
      allActivity.sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp));

      res.json({
        success: true,
        data: allActivity,
        message: 'Activity log retrieved successfully',
      });
    } catch (error) {
      console.error('Get activity error:', error);
      res.status(500).json({
        success: false,
        message: 'Server error',
      });
    }
  }
);

module.exports = router;
