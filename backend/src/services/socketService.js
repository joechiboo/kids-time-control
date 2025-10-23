const logger = require('../utils/logger');
const { verifyToken } = require('../utils/auth');

// Store connected clients
const connectedDevices = new Map();

function setupSocketHandlers(io) {
  // Authentication middleware
  io.use(async (socket, next) => {
    try {
      const token = socket.handshake.auth.token;
      if (!token) {
        return next(new Error('Authentication error'));
      }

      const decoded = await verifyToken(token);
      socket.userId = decoded.userId;
      socket.userRole = decoded.role;
      socket.familyId = decoded.familyId;
      next();
    } catch (err) {
      next(new Error('Authentication error'));
    }
  });

  io.on('connection', (socket) => {
    logger.info(`User ${socket.userId} connected`);

    // Store device info
    connectedDevices.set(socket.userId, {
      socketId: socket.id,
      role: socket.userRole,
      familyId: socket.familyId,
      connectedAt: new Date()
    });

    // Join family room
    socket.join(`family:${socket.familyId}`);

    // Handle device status updates
    socket.on('device:status', (data) => {
      handleDeviceStatus(socket, data);
    });

    // Handle usage updates from child devices
    socket.on('usage:update', (data) => {
      handleUsageUpdate(socket, data);
    });

    // Handle lock commands from parent
    socket.on('device:lock', (data) => {
      handleDeviceLock(socket, data);
    });

    // Handle unlock commands from parent
    socket.on('device:unlock', (data) => {
      handleDeviceUnlock(socket, data);
    });

    // Handle time limit reached
    socket.on('limit:reached', (data) => {
      handleLimitReached(socket, data);
    });

    // Handle disconnection
    socket.on('disconnect', () => {
      logger.info(`User ${socket.userId} disconnected`);
      connectedDevices.delete(socket.userId);

      // Notify family members
      socket.to(`family:${socket.familyId}`).emit('device:offline', {
        userId: socket.userId,
        timestamp: new Date()
      });
    });
  });
}

function handleDeviceStatus(socket, data) {
  // Update device status in database
  const deviceInfo = {
    userId: socket.userId,
    ...data,
    timestamp: new Date()
  };

  // Notify parent devices in the family
  socket.to(`family:${socket.familyId}`).emit('device:status:update', deviceInfo);
}

function handleUsageUpdate(socket, data) {
  // Store usage data
  const usageData = {
    userId: socket.userId,
    appName: data.appName,
    duration: data.duration,
    timestamp: new Date()
  };

  // Notify parent devices
  socket.to(`family:${socket.familyId}`).emit('usage:updated', usageData);
}

function handleDeviceLock(socket, data) {
  // Only parents can lock devices
  if (socket.userRole !== 'parent') {
    socket.emit('error', { message: 'Unauthorized action' });
    return;
  }

  const targetDevice = connectedDevices.get(data.childId);
  if (targetDevice) {
    io.to(targetDevice.socketId).emit('lock:device', {
      reason: data.reason || 'Time limit reached',
      lockedBy: socket.userId,
      timestamp: new Date()
    });
  }
}

function handleDeviceUnlock(socket, data) {
  // Only parents can unlock devices
  if (socket.userRole !== 'parent') {
    socket.emit('error', { message: 'Unauthorized action' });
    return;
  }

  const targetDevice = connectedDevices.get(data.childId);
  if (targetDevice) {
    io.to(targetDevice.socketId).emit('unlock:device', {
      unlockedBy: socket.userId,
      extraMinutes: data.extraMinutes || 0,
      timestamp: new Date()
    });
  }
}

function handleLimitReached(socket, data) {
  // Notify parents when child reaches time limit
  socket.to(`family:${socket.familyId}`).emit('limit:notification', {
    childId: socket.userId,
    limitType: data.limitType,
    timestamp: new Date()
  });
}

module.exports = {
  setupSocketHandlers,
  connectedDevices
};