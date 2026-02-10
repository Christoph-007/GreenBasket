const Wallet = require('../models/Wallet');

// Add cashback to wallet
async function addCashback(userId, amount, orderId, description) {
    try {
        let wallet = await Wallet.findOne({ user: userId });

        if (!wallet) {
            wallet = await Wallet.create({
                user: userId,
                balance: 0,
                transactions: []
            });
        }

        const balanceBefore = wallet.balance;
        wallet.balance += amount;

        wallet.transactions.push({
            type: 'credit',
            amount,
            source: 'cashback',
            description: description || `Cashback for order ${orderId}`,
            orderId,
            balanceBefore,
            balanceAfter: wallet.balance,
            status: 'completed'
        });

        await wallet.save();

        return {
            success: true,
            newBalance: wallet.balance
        };
    } catch (error) {
        console.error('Cashback error:', error);
        return { success: false, error: error.message };
    }
}

// Add referral bonus
async function addReferralBonus(userId, amount, referredUserId) {
    try {
        let wallet = await Wallet.findOne({ user: userId });

        if (!wallet) {
            wallet = await Wallet.create({
                user: userId,
                balance: 0,
                transactions: []
            });
        }

        const balanceBefore = wallet.balance;
        wallet.balance += amount;

        wallet.transactions.push({
            type: 'credit',
            amount,
            source: 'referral',
            description: `Referral bonus for referring user`,
            referenceId: referredUserId,
            balanceBefore,
            balanceAfter: wallet.balance,
            status: 'completed'
        });

        await wallet.save();

        return {
            success: true,
            newBalance: wallet.balance
        };
    } catch (error) {
        console.error('Referral bonus error:', error);
        return { success: false, error: error.message };
    }
}

module.exports = {
    addCashback,
    addReferralBonus
};
