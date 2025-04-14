# Expense Tracker

A comprehensive expense and income tracking application built with Flutter. This app helps users manage their personal finances by tracking expenses, income, setting budgets, and providing insightful reports.

![Expense Tracker App](screenshots/dashboard.png)

## Features

### Financial Management
- **Expense & Income Tracking**: Categorize and log all financial transactions
- **Multi-Currency Support**: Add expenses and income in different currencies with automatic conversion
- **Budget Management**: Create and track budgets by category and time period
- **Financial Reports**: View spending patterns, trends, and financial health metrics

### User Experience
- **Responsive Design**: Works flawlessly on all device sizes
- **Dark & Light Themes**: Choose your preferred viewing mode
- **Intuitive Dashboard**: See your financial status at a glance
- **Customizable Categories**: Tailor the app to your specific needs

### Authentication & Security
- **User Accounts**: Create personal accounts for secure access
- **Profile Management**: Update user information and preferences
- **Demo Mode**: Try the app with a pre-populated demo account
- **Local Data Storage**: All your data stays securely on your device

## Screenshots

| Dashboard | Reports | Budgets | Settings |
|-----------|---------|---------|----------|
| ![Dashboard](screenshots/dashboard.png) | ![Reports](screenshots/reports.png) | ![Budgets](screenshots/budgets.png) | ![Settings](screenshots/settings.png) |

## Getting Started

### Prerequisites
- Flutter SDK (version 3.0+)
- Dart (version 2.17+)
- Android Studio / VS Code
- Android SDK / Xcode (for iOS development)

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/expense_tracker.git
   ```

2. Navigate to the project directory:
   ```bash
   cd expense_tracker
   ```

3. Install dependencies:
   ```bash
   flutter pub get
   ```

4. Run the app:
   ```bash
   flutter run
   ```

## Usage Guide

### Adding Transactions
1. Use the "+" button to add a new expense
2. Use the "Income" button to add new income
3. Select categories, enter amounts, and add dates for each transaction

### Budget Management
1. Navigate to the Budgets screen
2. Create new budgets with specific categories and time periods
3. Monitor your budget progress through visual indicators

### Reports & Analysis
1. View the Reports screen for insights into your spending patterns
2. Filter reports by date ranges or categories
3. Export reports for external use (coming soon)

## Authentication

The app includes a secure authentication system:
- Register with your email and password (minimum 6 characters)
- Login with your credentials
- Demo account available for testing:
  - Email: demo@example.com
  - Password: password

## Technical Implementation

### Architecture
- **Models**: Structured data models for expenses, income, budgets, and user profiles
- **Services**: Specialized services for data persistence, settings, and authentication
- **Screens**: Responsive UI screens for different app sections
- **Widgets**: Reusable components for consistent UI elements

### Data Storage
All data is stored locally on the device using SharedPreferences:
- Transaction records (expenses and incomes)
- Budget configurations
- User settings and preferences
- User profiles and authentication information

### UI/UX Design
- Material Design principles
- Responsive layouts for all screen sizes
- Animated transitions for a fluid experience
- Accessibility considerations

## Roadmap

Future enhancements planned for the app:
- **Cloud Synchronization**: Sync data across multiple devices
- **Advanced Analytics**: More detailed financial insights and predictions
- **Data Export**: Export to CSV, PDF, and other formats
- **Smart Budgeting**: AI-powered budget recommendations
- **Receipt Scanning**: OCR functionality to capture receipts
- **Recurring Transactions**: Support for subscription and recurring payments
- **Financial Goals**: Set and track savings and financial goals
- **Multi-language Support**: Internationalization for global users

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgements

- [Flutter](https://flutter.dev/) - UI toolkit
- [Dart](https://dart.dev/) - Programming language
- [Material Design](https://material.io/) - Design system
- [SharedPreferences](https://pub.dev/packages/shared_preferences) - Local storage

