# Login Issue Testing Guide

## Problem
Login works but user data is not showing up in the student dashboard.

## Steps to Debug

### 1. Test Database Connection
- Open browser and go to: `http://localhost:8080/api/auth/debug/users`
- You should see a list of all users in the database
- If you see "Connection error" or empty, the database is not connected properly

### 2. Test Login with Different Emails

Try logging in with these emails (password: `hashed_password`):

**Student Emails:**
- `ali.ahmed@student.uni.edu` (Official mail)
- `student.ali@mail.com` (Personal email)

Both should work as the backend checks both fields.

### 3. Check Console Output

When you run the app and login, check the console for these messages:

```
Loading user data for email: <email>
Calling getUserByEmail with: <email>
API: getUserByEmail called with email: <email>
API: URL: http://localhost:8080/api/auth/get-user-by-email
API: Response status code: 200
API: Response body: <response>
```

### 4. Common Issues

**Issue 1: User not found**
- Check if you're using the exact email from the database
- Check console logs to see what email is being sent

**Issue 2: Connection refused**
- Make sure backend is running on port 8080
- Check `application.properties` for correct database credentials

**Issue 3: Wrong email passed**
- The login uses whatever you type in the email field
- Make sure you're typing the exact email (case-sensitive)

## Expected Behavior

1. Login with any student email + password `hashed_password`
2. Should redirect to student dashboard
3. Dashboard should show:
   - Student name in sidebar
   - Student info in profile
   - Course data
   - GPA and credits

## Quick Fix

If still not working, try:
1. Restart the backend server
2. Make sure the SQL script was executed
3. Clear app data and login again
4. Check the console output for specific error messages
