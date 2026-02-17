const fs = require('fs');

const endpoints = {
    Authentication: {
        userSignup: 'POST /api/auth/user/signup',
        userLogin: 'POST /api/auth/user/login',
        verifyEmail: 'POST /api/auth/user/verify-email',
        forgotPassword: 'POST /api/auth/user/forgot-password',
        resetPassword: 'POST /api/auth/user/reset-password',
        merchantSignup: 'POST /api/auth/merchant/signup',
        merchantLogin: 'POST /api/auth/merchant/login',
        adminLogin: 'POST /api/auth/admin/login',
        refreshToken: 'POST /api/auth/refresh-token',
        logout: 'POST /api/auth/logout'
    },
    Products: {
        getAll: 'GET /api/products',
        search: 'GET /api/products/search',
        getById: 'GET /api/products/:id',
        create: 'POST /api/products',
        update: 'PUT /api/products/:id',
        delete: 'DELETE /api/products/:id',
        updateStock: 'PATCH /api/products/:id/stock',
        getMyProducts: 'GET /api/products/merchant/my-products'
    },
    Categories: {
        getAll: 'GET /api/categories',
        getById: 'GET /api/categories/:id',
        create: 'POST /api/categories',
        update: 'PUT /api/categories/:id',
        delete: 'DELETE /api/categories/:id'
    },
    Cart: {
        getCart: 'GET /api/cart',
        addToCart: 'POST /api/cart/add',
        updateItem: 'PUT /api/cart/update/:productId',
        removeItem: 'DELETE /api/cart/remove/:productId',
        clearCart: 'DELETE /api/cart/clear',
        addRecipe: 'POST /api/cart/recipe-to-cart'
    },
    Orders: {
        create: 'POST /api/orders',
        getMyOrders: 'GET /api/orders/my-orders',
        getById: 'GET /api/orders/:id',
        cancel: 'PATCH /api/orders/:id/cancel',
        getMerchantOrders: 'GET /api/orders/merchant/orders',
        updateStatus: 'PATCH /api/orders/merchant/:id/status',
        updateLocation: 'PATCH /api/orders/:id/location'
    },
    Recipes: {
        getAll: 'GET /api/recipes',
        search: 'GET /api/recipes/search',
        getById: 'GET /api/recipes/:id',
        calculateIngredients: 'POST /api/recipes/:id/calculate-ingredients',
        create: 'POST /api/recipes',
        update: 'PUT /api/recipes/:id',
        delete: 'DELETE /api/recipes/:id'
    },
    Reviews: {
        getProductReviews: 'GET /api/reviews/product/:productId',
        getMerchantReviews: 'GET /api/reviews/merchant/:merchantId',
        deleteReview: 'DELETE /api/reviews/:id'
    },
    Subscriptions: {
        create: 'POST /api/subscriptions',
        getMySubscriptions: 'GET /api/subscriptions',
        updateStatus: 'PATCH /api/subscriptions/:id/status'
    },
    Users: {
        getProfile: 'GET /api/users/profile',
        updateProfile: 'PUT /api/users/profile',
        getAddresses: 'GET /api/users/addresses',
        addAddress: 'POST /api/users/addresses',
        updateAddress: 'PUT /api/users/addresses/:id',
        deleteAddress: 'DELETE /api/users/addresses/:id',
        getNotificationPreferences: 'GET /api/users/notification-preferences',
        updateNotificationPreferences: 'PUT /api/users/notification-preferences',
        registerFCMToken: 'POST /api/users/fcm-token',
        removeFCMToken: 'DELETE /api/users/fcm-token'
    },
    Merchants: {
        getProfile: 'GET /api/merchants/profile',
        updateProfile: 'PUT /api/merchants/profile',
        toggleStore: 'PATCH /api/merchants/toggle-store',
        getDashboard: 'GET /api/merchants/dashboard-stats'
    },
    Admin: {
        getPendingMerchants: 'GET /api/admin/merchants/pending',
        verifyMerchant: 'PATCH /api/admin/merchants/:id/verify',
        getUsers: 'GET /api/admin/users',
        toggleUserBlock: 'PATCH /api/admin/users/:id/block',
        getPlatformStats: 'GET /api/admin/stats'
    },
    Upload: {
        uploadImage: 'POST /api/upload/image',
        uploadMultipleImages: 'POST /api/upload/images',
        uploadDocument: 'POST /api/upload/document',
        getMyUploads: 'GET /api/upload/my-uploads',
        getUploadById: 'GET /api/upload/:uploadId',
        deleteUpload: 'DELETE /api/upload/:uploadId',
        bulkDelete: 'POST /api/upload/bulk-delete',
        updateProductImages: 'PUT /api/upload/products/:productId/images'
    },
    Payment: {
        createOrder: 'POST /api/payment/create-order',
        verifyPayment: 'POST /api/payment/verify',
        processRefund: 'POST /api/payment/refund'
    },
    Notifications: {
        getNotifications: 'GET /api/notifications',
        getUnreadCount: 'GET /api/notifications/unread-count',
        markAsRead: 'PATCH /api/notifications/:id/read',
        markAllAsRead: 'PATCH /api/notifications/read-all',
        deleteNotification: 'DELETE /api/notifications/:id',
        clearAll: 'DELETE /api/notifications/clear-all',
        sendTest: 'POST /api/notifications/admin/test',
        bulkSend: 'POST /api/notifications/admin/bulk-send'
    },
    Wishlist: {
        getWishlist: 'GET /api/wishlist',
        addToWishlist: 'POST /api/wishlist/add',
        removeFromWishlist: 'DELETE /api/wishlist/remove/:productId',
        moveToCart: 'POST /api/wishlist/move-to-cart/:productId',
        checkWishlisted: 'GET /api/wishlist/check/:productId'
    },
    Wallet: {
        getWallet: 'GET /api/wallet',
        getTransactions: 'GET /api/wallet/transactions',
        addMoney: 'POST /api/wallet/add-money',
        verifyTopup: 'POST /api/wallet/verify-topup',
        useForPayment: 'POST /api/wallet/use-for-payment',
        adminCredit: 'POST /api/wallet/admin/credit',
        lockUnlock: 'PATCH /api/wallet/admin/:userId/lock',
        creditRefund: 'POST /api/wallet/credit-refund'
    },
    Loyalty: {
        redeemPoints: 'POST /api/loyalty/redeem',
        getHistory: 'GET /api/loyalty/history',
        getBenefits: 'GET /api/loyalty/benefits',
        awardPoints: 'POST /api/loyalty/award'
    },
    Referral: {
        generateCode: 'POST /api/referral/generate',
        getStats: 'GET /api/referral/stats',
        applyCode: 'POST /api/referral/apply',
        validateCode: 'GET /api/referral/validate/:code',
        processReward: 'POST /api/referral/process-reward'
    },
    Offers: {
        createOffer: 'POST /api/offers',
        getMerchantOffers: 'GET /api/offers/merchant',
        getAvailableOffers: 'GET /api/offers/available',
        applyCoupon: 'POST /api/offers/cart/apply-coupon',
        removeCoupon: 'DELETE /api/offers/cart/remove-coupon',
        updateOffer: 'PUT /api/offers/:id',
        deleteOffer: 'DELETE /api/offers/:id',
        getOfferAnalytics: 'GET /api/offers/:id/analytics',
        getFlashSales: 'GET /api/offers/flash-sales',
        getAllOffers: 'GET /api/offers/admin/all'
    },
    MerchantAnalytics: {
        salesAnalytics: 'GET /api/merchants/analytics/sales',
        productAnalytics: 'GET /api/merchants/analytics/products',
        customerAnalytics: 'GET /api/merchants/analytics/customers',
        inventoryAnalytics: 'GET /api/merchants/analytics/inventory',
        revenueForecast: 'GET /api/merchants/analytics/forecast',
        reviewAnalytics: 'GET /api/merchants/analytics/reviews'
    },
    DeliveryZones: {
        setLocation: 'PUT /api/merchants/zones/location',
        getZones: 'GET /api/merchants/zones/delivery-zones',
        addZone: 'POST /api/merchants/zones/delivery-zones',
        updateZone: 'PUT /api/merchants/zones/delivery-zones/:zoneId',
        deleteZone: 'DELETE /api/merchants/zones/delivery-zones/:zoneId',
        checkDelivery: 'POST /api/merchants/zones/check-delivery',
        getNearbyMerchants: 'POST /api/merchants/zones/nearby'
    },
    Membership: {
        getPlans: 'GET /api/membership/plans',
        getMembership: 'GET /api/membership',
        subscribe: 'POST /api/membership/subscribe',
        cancel: 'POST /api/membership/cancel',
        getPremiumProducts: 'GET /api/membership/premium-products',
        checkBenefit: 'GET /api/membership/check-benefit'
    },
    PreBooking: {
        create: 'POST /api/prebooking',
        getMyPreBookings: 'GET /api/prebooking/my-prebookings',
        cancel: 'DELETE /api/prebooking/:id',
        convertToOrder: 'POST /api/prebooking/:id/convert-to-order',
        markAvailable: 'PATCH /api/prebooking/products/:id/mark-available',
        getAllPreBookings: 'GET /api/prebooking/admin/all'
    },
    DocumentVerification: {
        upload: 'POST /api/documents/upload',
        getDocuments: 'GET /api/documents',
        deleteDocument: 'DELETE /api/documents/:documentId',
        getPending: 'GET /api/documents/admin/pending',
        verify: 'PUT /api/documents/admin/:merchantId/:documentId/verify',
        getExpiring: 'GET /api/documents/admin/expiring-soon'
    },
    Disputes: {
        raiseDispute: 'POST /api/disputes',
        getMyDisputes: 'GET /api/disputes/my-disputes',
        getDisputeById: 'GET /api/disputes/:id',
        addMessage: 'POST /api/disputes/:id/message',
        escalate: 'PATCH /api/disputes/:id/escalate',
        getAllDisputes: 'GET /api/disputes/admin/all',
        resolveDispute: 'PUT /api/disputes/admin/:id/resolve',
        updateStatus: 'PATCH /api/disputes/admin/:id/status'
    },
    Financial: {
        getMerchantEarnings: 'GET /api/financial/merchants/earnings',
        getMerchantPayouts: 'GET /api/financial/merchants/payouts',
        getPayoutById: 'GET /api/financial/payouts/:id',
        getAllPayouts: 'GET /api/financial/admin/payouts',
        generatePayouts: 'POST /api/financial/admin/payouts/generate',
        processPayout: 'POST /api/financial/admin/payouts/:id/process',
        holdPayout: 'PATCH /api/financial/admin/payouts/:id/hold',
        getFinancialReports: 'GET /api/financial/admin/reports/financial',
        getGSTReport: 'GET /api/financial/admin/reports/gst',
        updateCommission: 'PUT /api/financial/admin/settings/commission'
    },
    BulkOperations: {
        bulkUpload: 'POST /api/bulk/products/bulk-upload',
        bulkUpdatePrice: 'PUT /api/bulk/products/bulk-update-price',
        bulkUpdateStock: 'PUT /api/bulk/products/bulk-update-stock',
        exportProducts: 'GET /api/bulk/products/export'
    },
    Search: {
        advancedSearch: 'GET /api/search/products',
        suggestions: 'GET /api/search/suggestions',
        trending: 'GET /api/search/trending'
    },
    Returns: {
        requestReturn: 'POST /api/returns',
        getMyReturns: 'GET /api/returns/my-returns',
        getReturnById: 'GET /api/returns/:id',
        cancelReturn: 'DELETE /api/returns/:id',
        getAllReturns: 'GET /api/returns/admin/all',
        processReturn: 'PUT /api/returns/admin/:id/process'
    },
    GiftCards: {
        checkBalance: 'GET /api/gift-cards/balance/:code',
        validateGiftCard: 'POST /api/gift-cards/validate',
        redeemGiftCard: 'POST /api/gift-cards/redeem',
        getMyGiftCards: 'GET /api/gift-cards/my-cards',
        generateGiftCard: 'POST /api/gift-cards/admin/generate',
        getAllGiftCards: 'GET /api/gift-cards/admin/all',
        cancelGiftCard: 'PATCH /api/gift-cards/admin/:id/cancel',
        initiatePurchase: 'POST /api/gift-cards/purchase/initiate',
        verifyPurchase: 'POST /api/gift-cards/purchase/verify'
    }
};

const collection = {
    info: {
        name: "Green Basket API Backup Test",
        schema: "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
    },
    item: []
};

for (const groupName in endpoints) {
    const folder = {
        name: groupName,
        item: []
    };

    for (const requestName in endpoints[groupName]) {
        const value = endpoints[groupName][requestName];
        const [method, path] = value.split(' ');

        // Clean path (remove (Role) suffix if present)
        const cleanPath = path.replace(/\s\([a-zA-Z]+\)$/, '');

        // Convert :id to {{id}} for Postman variables
        const postmanPath = cleanPath.split('/').map(segment => {
            if (segment.startsWith(':')) {
                return `{{${segment.substring(1)}}}`;
            }
            return segment;
        });

        const requestItem = {
            name: requestName,
            request: {
                method: method,
                header: [
                    {
                        key: "Authorization",
                        value: "Bearer {{token}}",
                        type: "text"
                    },
                    {
                        key: "Content-Type",
                        value: "application/json",
                        type: "text"
                    }
                ],
                url: {
                    raw: `{{base_url}}${cleanPath}`,
                    host: ["{{base_url}}"],
                    path: postmanPath
                }
            }
        };

        // Add sample body for POST/PUT requests
        if (['POST', 'PUT', 'PATCH'].includes(method)) {
            requestItem.request.body = {
                mode: "raw",
                raw: "{\n    \n}",
                options: {
                    raw: { language: "json" }
                }
            };
        }

        folder.item.push(requestItem);
    }
    collection.item.push(folder);
}

fs.writeFileSync('greenbasket_postman_collection.json', JSON.stringify(collection, null, 2));
console.log('Postman collection generated!');
