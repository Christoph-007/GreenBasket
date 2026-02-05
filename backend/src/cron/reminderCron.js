const cron = require('node-cron');

const scheduleReminders = () => {
    // Run every hour
    cron.schedule('0 * * * *', () => {
        console.log('Running Reminder Cron Job...');
        // TODO: Implement reminder logic (e.g. abandoned carts, scheduled pickups)
    });
};

module.exports = scheduleReminders;
