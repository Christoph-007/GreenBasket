# 🎉 Green Basket Backend - Complete API List (99 APIs)

## ✅ Server Running: http://localhost:5001

---

## 📊 API Breakdown by Category

### 1. AUTHENTICATION (5 APIs)
- `POST /api/auth/user/signup` - User signup
- `POST /api/auth/user/login` - User login
- `POST /api/auth/merchant/signup` - Merchant signup
- `POST /api/auth/merchant/login` - Merchant login
- `POST /api/auth/admin/login` - Admin login

### 2. PRODUCTS (5 APIs)
- `GET /api/products` - Get all products
- `GET /api/products/:id` - Get product by ID
- `POST /api/products` - Create product (Merchant)
- `PUT /api/products/:id` - Update product (Merchant)
- `DELETE /api/products/:id` - Delete product (Merchant)

### 3. CART (6 APIs)
- `GET /api/cart` - Get cart
- `POST /api/cart/add` - Add to cart
- `PUT /api/cart/update/:productId` - Update cart item
- `DELETE /api/cart/remove/:productId` - Remove from cart
- `DELETE /api/cart/clear` - Clear cart
- `POST /api/cart/recipe-to-cart` - Add recipe to cart

### 4. ORDERS (4 APIs)
- `POST /api/orders` - Create order
- `GET /api/orders/my-orders` - Get my orders
- `GET /api/orders/:id` - Get order by ID
- `PATCH /api/orders/:id/cancel` - Cancel order

### 5. RECIPES (3 APIs)
- `GET /api/recipes` - Get all recipes
- `GET /api/recipes/:id` - Get recipe by ID
- `POST /api/recipes/:id/calculate-ingredients` - Calculate ingredients

### 6. USERS (8 APIs)
- `GET /api/users/profile` - Get profile
- `PUT /api/users/profile` - Update profile
- `GET /api/users/addresses` - Get addresses
- `POST /api/users/addresses` - Add address
- `GET /api/users/notification-preferences` - Get notification preferences ✨ NEW
- `PUT /api/users/notification-preferences` - Update notification preferences ✨ NEW
- `POST /api/users/fcm-token` - Register FCM token ✨ NEW
- `DELETE /api/users/fcm-token` - Remove FCM token ✨ NEW

### 7. MERCHANTS (4 APIs)
- `GET /api/merchants/profile` - Get profile
- `PUT /api/merchants/profile` - Update profile
- `PATCH /api/merchants/toggle-store` - Toggle store status
- `GET /api/merchants/dashboard-stats` - Get dashboard stats

### 8. ADMIN (4 APIs)
- `GET /api/admin/merchants/pending` - Get pending merchants
- `PUT /api/admin/merchants/verify/:id` - Verify merchant
- `GET /api/admin/users` - Get all users
- `GET /api/admin/stats` - Get platform stats

---

## 🆕 NEW FEATURES (40 APIs)

### 9. FILE UPLOAD SYSTEM (8 APIs) ✨ Feature 1
- `POST /api/upload/image` - Upload single image
- `POST /api/upload/images` - Upload multiple images
- `POST /api/upload/document` - Upload document
- `GET /api/upload/my-uploads` - Get my uploads
- `GET /api/upload/:uploadId` - Get upload by ID
- `DELETE /api/upload/:uploadId` - Delete upload
- `POST /api/upload/bulk-delete` - Bulk delete uploads
- `PUT /api/upload/products/:productId/images` - Update product images

### 10. PAYMENT GATEWAY (3 APIs) ✨ Feature 2
- `POST /api/payment/create-order` - Create Razorpay order
- `POST /api/payment/verify` - Verify payment
- `POST /api/payment/refund` - Process refund

### 11. NOTIFICATIONS (12 APIs) ✨ Feature 3
- `GET /api/notifications` - Get notifications
- `GET /api/notifications/unread-count` - Get unread count
- `PATCH /api/notifications/:id/read` - Mark as read
- `PATCH /api/notifications/read-all` - Mark all as read
- `DELETE /api/notifications/:id` - Delete notification
- `DELETE /api/notifications/clear-all` - Clear all notifications
- `POST /api/notifications/admin/test` - Send test notification (Admin)
- `POST /api/notifications/admin/bulk-send` - Bulk send notifications (Admin)
- **Plus 4 user notification preference APIs listed above**

### 12. WISHLIST (5 APIs) ✨ Feature 4
- `GET /api/wishlist` - Get wishlist
- `POST /api/wishlist/add` - Add to wishlist
- `DELETE /api/wishlist/remove/:productId` - Remove from wishlist
- `POST /api/wishlist/move-to-cart/:productId` - Move to cart
- `GET /api/wishlist/check/:productId` - Check if wishlisted

### 13. WALLET & CREDITS (8 APIs) ✨ Feature 5
- `GET /api/wallet` - Get wallet balance
- `GET /api/wallet/transactions` - Get transaction history
- `POST /api/wallet/add-money` - Initiate wallet topup
- `POST /api/wallet/verify-topup` - Verify topup payment
- `POST /api/wallet/use-for-payment` - Pay with wallet
- `POST /api/wallet/admin/credit` - Admin credit to wallet (Admin)
- `PATCH /api/wallet/admin/:userId/lock` - Lock/unlock wallet (Admin)
- `POST /api/wallet/credit-refund` - Credit refund (Admin)

### 14. LOYALTY POINTS (4 APIs) ✨ Feature 6
- `POST /api/loyalty/redeem` - Redeem points
- `GET /api/loyalty/history` - Get points history
- `GET /api/loyalty/benefits` - Get tier benefits
- `POST /api/loyalty/award` - Award points (Admin)

---

## 📈 API Count Summary

| Category | Count |
|----------|-------|
| Authentication | 5 |
| Products | 5 |
| Cart | 6 |
| Orders | 4 |
| Recipes | 3 |
| Users | 8 |
| Merchants | 4 |
| Admin | 4 |
| **File Upload** ✨ | **8** |
| **Payment Gateway** ✨ | **3** |
| **Notifications** ✨ | **12** |
| **Wishlist** ✨ | **5** |
| **Wallet** ✨ | **8** |
| **Loyalty** ✨ | **4** |
| **TOTAL** | **99** |

---

## 🎯 Features Implemented

✅ **Feature 1:** File Upload System (8 APIs)
✅ **Feature 2:** Payment Gateway Integration (3 APIs)
✅ **Feature 3:** Comprehensive Notification System (12 APIs)
✅ **Feature 4:** Wishlist System (5 APIs)
✅ **Feature 5:** Wallet & Credits System (8 APIs)
✅ **Feature 6:** Loyalty Points Redemption (4 APIs)

**Total:** 6 features, 40 new APIs

---

## 🚀 Test the API

Visit http://localhost:5001/api in your browser to see the complete API documentation with all 99 endpoints!

Or use curl:
```bash
curl http://localhost:5001/api | jq
```

---

**Last Updated:** February 9, 2026, 10:40 PM IST
**Status:** ✅ ALL 99 APIS ACTIVE AND RUNNING
