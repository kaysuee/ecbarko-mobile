# Constant Dialog System

## 🎯 **What is this?**

`constant_dialog.dart` is a **consolidated dialog system** that combines:
- ✅ All dialog types (success, error, warning, info, confirmation, action, custom)
- ✅ Usage examples for each dialog type
- ✅ Migration guide for existing dialogs
- ✅ Integration strategy for using both custom and uniform dialogs
- ✅ Complete documentation and examples

## 🚀 **Quick Start**

### **1. Import the file:**
```dart
import '../widgets/constant_dialog.dart';
```

### **2. Use any dialog type:**
```dart
// Success Dialog
ConstantDialog.showSuccessDialog(
  context: context,
  title: 'Success!',
  message: 'Your action was completed successfully.',
  confirmText: 'Continue',
);

// Error Dialog
ConstantDialog.showErrorDialog(
  context: context,
  message: 'Something went wrong.',
  title: 'Error',
  confirmText: 'Try Again',
);

// Confirmation Dialog
final result = await ConstantDialog.showConfirmationDialog(
  context: context,
  title: 'Confirm Action',
  message: 'Are you sure?',
  confirmText: 'Yes',
  cancelText: 'No',
);
```

## 📱 **Available Dialog Types**

| Dialog Type | Method | Use Case |
|-------------|---------|----------|
| **Success** | `showSuccessDialog()` | ✅ Successful operations |
| **Error** | `showErrorDialog()` | ❌ Error messages |
| **Warning** | `showWarningDialog()` | ⚠️ Warnings |
| **Info** | `showInfoDialog()` | ℹ️ Information |
| **Confirmation** | `showConfirmationDialog()` | 🤔 User confirmation |
| **Action** | `showActionDialog()` | 🎯 Multiple actions |
| **Custom** | `showCustomDialog()` | 🎨 Custom layouts |

## 🔄 **Migration from Old System**

### **Before (UniformDialogs):**
```dart
UniformDialogs.showSuccessDialog(...)
```

### **After (ConstantDialog):**
```dart
ConstantDialog.showSuccessDialog(...)
```

## 💡 **Pro Tips**

1. **Keep using** your existing `custom_dialog.dart` for simple cases
2. **Use** `ConstantDialog` for better UX and consistent theming
3. **Replace SnackBars** with appropriate dialogs for important messages
4. **Customize colors** in the file to match your app theme

## 📁 **What's Inside**

- **Core Dialog System** - All dialog implementations
- **Usage Examples** - Practical examples for each dialog type
- **Migration Guide** - How to replace existing dialogs
- **Integration Strategy** - How to use both systems together

## 🎨 **Customization**

Change colors at the top of the file:
```dart
static const Color _successColor = Colors.green;  // Your brand color
static const Color _errorColor = Colors.red;      // Your brand color
static const Color _warningColor = Colors.orange; // Your brand color
static const Color _infoColor = Ec_PRIMARY;       // Already using your brand color
```

## 🆘 **Need Help?**

Everything you need is in the `constant_dialog.dart` file:
- Check the **usage examples** for practical code
- Look at the **migration guide** for step-by-step instructions
- Read the **integration strategy** for best practices

**Happy coding! 🚀✨**
