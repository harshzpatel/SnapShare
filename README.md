# SnapShare - Social Media Platform

A modern, feature-rich social media application built with Flutter and Firebase. Share your moments, connect with friends, and discover amazing content in a beautifully designed platform that prioritizes user experience and real-time interactions.

## 🚀 Features

### Authentication
- **User Registration** - Create new accounts with email and password
- **User Login** - Secure authentication with Firebase Auth
- **Profile Management** - Upload profile pictures and manage user bio

### Social Features
- **Photo Sharing** - Upload and share photos with captions
- **Feed** - View posts from all users in a beautiful timeline
- **Like System** - Like and unlike posts with smooth animations
- **Comments** - Comment on posts and engage with other users
- **User Profiles** - View user profiles with their posts and stats
- **Follow System** - Follow/unfollow other users
- **Search** - Discover and search for users

### UI/UX
- **Smooth Animations** - Beautiful like animations and transitions
- **Material Design** - Clean, modern interface following Material Design principles
- **Custom Fonts** - Google Fonts integration for better typography
- **SVG Icons** - Crisp vector icons throughout the app

[//]: # (## 📱 Screenshots)

[//]: # ()
[//]: # (*Add your app screenshots here*)

## 🛠 Tech Stack

- **Frontend**: Flutter (Dart)
- **Backend**: Firebase
- **Database**: Cloud Firestore
- **Authentication**: Firebase Auth
- **Storage**: Firebase Storage
- **State Management**: Provider
- **UI Components**: Material Design

## 📦 Dependencies

### Core Dependencies
- `firebase_core` - Firebase SDK initialization
- `cloud_firestore` - NoSQL database for storing posts, users, and comments
- `firebase_auth` - User authentication and management
- `firebase_storage` - Cloud storage for images
- `provider` - State management solution
- `image_picker` - Camera and gallery access for photo selection

### UI/UX Dependencies
- `flutter_svg` - SVG image support
- `transparent_image` - Smooth image loading
- `flutter_staggered_grid_view` - Responsive grid layouts
- `timeago` - Human-readable time formatting
- `google_fonts` - Custom typography
- `uuid` - Unique identifier generation

## 🏗 Project Structure

```
lib/
├── models/           # Data models (User, Post)
├── screens/          # App screens and pages
├── widgets/          # Reusable UI components
├── providers/        # State management
├── resources/        # Firebase services and API calls
├── utils/           # Utility functions and constants
└── theme/           # App theming and styling
```

### Key Files
- `models/user.dart` - User data model
- `models/post.dart` - Post data model
- `providers/user_provider.dart` - User state management
- `resources/auth_methods.dart` - Authentication services
- `resources/firestore_methods.dart` - Database operations
- `resources/storage_methods.dart` - File upload services

## 🎯 What Makes SnapShare Special

### Seamless User Experience
- Intuitive navigation and smooth interactions
- Fast loading times with optimized image handling
- Real-time updates and notifications

### Performance
- Optimized for mobile performance
- Efficient state management
- Smooth animations and transitions

## 🚀 Getting Started

1. **Create Account** - Sign up with your email and choose a unique username
2. **Set Up Profile** - Add a profile picture and write a bio to introduce yourself
3. **Start Sharing** - Upload your first photo and share your story
4. **Connect** - Discover and follow interesting users
5. **Engage** - Like, comment, and interact with the community

