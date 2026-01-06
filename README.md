# SplitSmart 💰

**SplitSmart** is a Flutter-based **expense splitter and debt tracker app**.  
It helps you **split expenses intelligently**, manage **groups**, and keep track of who owes what — all with smooth **state management using Provider** and **Firebase backend**.

---

## Video demonstration

https://drive.google.com/file/d/1ENV7nNZ_ISBojUq1raiuOK3AhWWrJsrT/view?usp=sharing

---

## 🚀 Features

- **Group-Based Expense Tracking**: Create multiple groups and track shared expenses.
- **Smart Expense Splitting**:
    - Split expenses **equally** or **custom amounts**
    - Automatically calculate who owes whom
    - **Clear dues smartly** (e.g., if you owe 50 and someone owes you 100, after clearing you will owe 0 and be owed 50)
- **Profile Management**: Update user profile info and settings
- **State Management**: Smooth UI updates using **Provider**
- **Themes**: Light and dark mode support
- **Firebase Integration**: Real-time database syncing for groups and transactions
- **Transaction History**: View past expenses and settlements

---

## 🛠️ Tech Stack

- **Flutter & Dart**
- **State Management:** Provider
- **Backend:** Firebase Firestore
- **Authentication:** Firebase Auth
- **UI & Themes:** Flutter Material Design

---

## 📱 How It Works

1. **Create a Group** → add members
2. **Add Expense** → choose **equal** or **custom split**
3. **Track Balances** → see who owes whom
4. **Clear Dues** → smart clearing of debts
5. **Update Profile** → manage your user info and preferences

**Example:**
- You owe Alice 50
- Bob owes you 100
- After clearing:
    - You owe Alice 0
    - Bob owes you 50

---

## ⚙️ Getting Started

### Prerequisites
- Flutter SDK installed
- Android Studio / VS Code
- Firebase project configured with Firestore & Auth

### Setup Steps

1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/splitsmart.git
   cd splitsmart
   
2. Install dependencies:
   ```bash
   flutter pub get
      
3. Add your Firebase config files:
   google-services.json for Android

   GoogleService-Info.plist for iOS

4. Run the app:
    ```bash
    flutter run

### 🎯 Purpose of This Project

SplitSmart was built to:

    1. Handle group expenses efficiently
    2. Demonstrate offline + online Firebase syncing
    3. Showcase Provider-based state management
    4. Implement smart debt clearing logic
    5. Build a clean, modern UI for finance apps

### 📌 Notes

Firebase must be configured locally to test real-time syncing

Supports equal and custom splits

Tracks and clears debts automatically for smarter settlements

### 👤 Author

Abdul Haseeb

Flutter Developer | Software Engineering Student
