const { createClient } = require('redis');

const redisClient = createClient({
    url: process.env.REDIS_URL
});

redisClient.on('error', (err) => console.log('Redis Client Error', err));
redisClient.on('connect', () => console.log('✅ Redis Connected'));

const connectRedis = async () => {
    try {
        await redisClient.connect();
    } catch (error) {
        console.log('Redis Connection Failed:', error);
    }
};

// Don't fail if redis is not available in dev
if (process.env.NODE_ENV !== 'test') {
    connectRedis();
}

module.exports = redisClient;
