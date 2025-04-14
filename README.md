# Expense Tracker

A comprehensive expense and income tracking application built with Flutter. Track your expenses, income, set budgets, and view reports.

## Features

### Core Functionality
- Track expenses and income with categories
- Set and manage budgets
- View reports and analytics
- Multi-currency support
- Dark and light theme support

### Authentication
- User login and registration
- Profile management
- Secure data storage
- Demo account for easy testing

## Getting Started

### Prerequisites
- Flutter SDK installed
- An IDE (VS Code, Android Studio, etc.)

### Installation
1. Clone the repository
   ```
   git clone https://github.com/yourusername/expense_tracker.git
   ```
2. Install dependencies
   ```
   flutter pub get
   ```
3. Run the app
   ```
   flutter run
   ```

## Authentication

The app includes a simple authentication system:
- New users can register by entering a valid email and password (minimum 6 characters)
- Existing users can log in with their credentials
- You can use the demo account for testing:
  - Email: demo@example.com
  - Password: password

## Data Storage

All data is stored locally on the device using SharedPreferences:
- Expenses and incomes
- User budgets
- User settings
- User profile

## Future Enhancements
- Cloud synchronization
- More detailed reports
- Export data to CSV/PDF
- Advanced budget rules

## License
This project is licensed under the MIT License - see the LICENSE file for details.
