# Firestore Security Rules

Copy and paste the following rules into your Firebase Console > Firestore Database > Rules tab.

These rules ensure that:
1. Only authenticated users can read/write.
2. Users can only access their own document in the `users` collection.

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Match any document in the 'users' collection
    match /users/{userId} {
      // Allow read and write only if the request's auth uid matches the document's userId
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Default deny for other collections (add more rules as you expand the app)
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```
