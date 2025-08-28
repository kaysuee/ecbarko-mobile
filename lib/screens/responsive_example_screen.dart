import 'package:flutter/material.dart';
import '../utils/responsive_utils.dart';
import '../widgets/responsive_widgets.dart';
import '../utils/responsive_layout.dart';
import '../constants.dart';

class ResponsiveExampleScreen extends StatefulWidget {
  const ResponsiveExampleScreen({super.key});

  @override
  State<ResponsiveExampleScreen> createState() =>
      _ResponsiveExampleScreenState();
}

class _ResponsiveExampleScreenState extends State<ResponsiveExampleScreen>
    with ResponsiveWidgetMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      appBar: AppBar(
        title: ResponsiveText(
          'Responsive Design Demo',
          fontSize: ResponsiveUtils.fontSizeXXL,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        backgroundColor: Ec_PRIMARY,
        iconTheme: IconThemeData(
          color: Colors.white,
          size: ResponsiveUtils.iconSizeM,
        ),
      ),
      body: ResponsiveContainer(
        child: ResponsiveListView(
          children: [
            _buildHeaderSection(),
            ResponsiveSpacing(height: ResponsiveUtils.spacingL),
            _buildResponsiveGrid(),
            ResponsiveSpacing(height: ResponsiveUtils.spacingL),
            _buildResponsiveForm(),
            ResponsiveSpacing(height: ResponsiveUtils.spacingL),
            _buildResponsiveCards(),
            ResponsiveSpacing(height: ResponsiveUtils.spacingL),
            _buildDeviceInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return ResponsiveCard(
      child: ResponsiveColumn(
        children: [
          ResponsiveText(
            'Welcome to Responsive Design!',
            fontSize: ResponsiveUtils.fontSizeXXXL,
            fontWeight: FontWeight.bold,
            textAlign: TextAlign.center,
          ),
          ResponsiveSpacing(height: ResponsiveUtils.spacingM),
          ResponsiveText(
            'This screen demonstrates how your app can automatically adapt to different device sizes and orientations.',
            fontSize: ResponsiveUtils.fontSizeL,
            textAlign: TextAlign.center,
            color: Colors.grey[600],
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveGrid() {
    return ResponsiveCard(
      child: ResponsiveColumn(
        children: [
          ResponsiveText(
            'Responsive Grid Layout',
            fontSize: ResponsiveUtils.fontSizeXXL,
            fontWeight: FontWeight.bold,
          ),
          ResponsiveSpacing(height: ResponsiveUtils.spacingM),
          ResponsiveGrid(
            children: [
              _buildGridItem('Item 1', Icons.star, Colors.blue),
              _buildGridItem('Item 2', Icons.favorite, Colors.red),
              _buildGridItem('Item 3', Icons.thumb_up, Colors.green),
              _buildGridItem('Item 4', Icons.check_circle, Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGridItem(String title, IconData icon, Color color) {
    return ResponsiveCard(
      color: color.withOpacity(0.1),
      child: ResponsiveColumn(
        children: [
          Icon(
            icon,
            size: ResponsiveUtils.iconSizeXL,
            color: color,
          ),
          ResponsiveSpacing(height: ResponsiveUtils.spacingS),
          ResponsiveText(
            title,
            fontSize: ResponsiveUtils.fontSizeM,
            fontWeight: FontWeight.w600,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveForm() {
    return ResponsiveCard(
      child: ResponsiveColumn(
        children: [
          ResponsiveText(
            'Responsive Form',
            fontSize: ResponsiveUtils.fontSizeXXL,
            fontWeight: FontWeight.bold,
          ),
          ResponsiveSpacing(height: ResponsiveUtils.spacingM),
          ResponsiveInputField(
            labelText: 'Email',
            hintText: 'Enter your email address',
            controller: _emailController,
            prefixIcon: Icon(Icons.email),
            keyboardType: TextInputType.emailAddress,
          ),
          ResponsiveSpacing(height: ResponsiveUtils.spacingM),
          ResponsiveInputField(
            labelText: 'Password',
            hintText: 'Enter your password',
            controller: _passwordController,
            prefixIcon: Icon(Icons.lock),
            obscureText: true,
          ),
          ResponsiveSpacing(height: ResponsiveUtils.spacingL),
          ResponsiveButton(
            'Submit',
            onPressed: () => _showSnackBar('Form submitted!'),
            backgroundColor: Ec_PRIMARY,
            textColor: Colors.white,
            width: double.infinity,
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveCards() {
    return ResponsiveCard(
      child: ResponsiveColumn(
        children: [
          ResponsiveText(
            'Responsive Cards',
            fontSize: ResponsiveUtils.fontSizeXXL,
            fontWeight: FontWeight.bold,
          ),
          ResponsiveSpacing(height: ResponsiveUtils.spacingM),
          ResponsiveRow(
            wrapOnSmallScreen: true,
            children: [
              Expanded(
                child: ResponsiveCard(
                  color: Colors.blue.withOpacity(0.1),
                  child: ResponsiveText(
                    'This card adapts to screen size',
                    fontSize: ResponsiveUtils.fontSizeM,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              ResponsiveSpacing(width: ResponsiveUtils.spacingM),
              Expanded(
                child: ResponsiveCard(
                  color: Colors.green.withOpacity(0.1),
                  child: ResponsiveText(
                    'Cards stack on small screens',
                    fontSize: ResponsiveUtils.fontSizeM,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceInfo() {
    return ResponsiveCard(
      child: ResponsiveColumn(
        children: [
          ResponsiveText(
            'Device Information',
            fontSize: ResponsiveUtils.fontSizeXXL,
            fontWeight: FontWeight.bold,
          ),
          ResponsiveSpacing(height: ResponsiveUtils.spacingM),
          _buildInfoRow('Screen Width', '${screenWidth.toStringAsFixed(0)}px'),
          _buildInfoRow(
              'Screen Height', '${screenHeight.toStringAsFixed(0)}px'),
          _buildInfoRow(
              'Device Type',
              isMobile
                  ? 'Mobile'
                  : isTablet
                      ? 'Tablet'
                      : 'Desktop'),
          _buildInfoRow('Orientation',
              screenWidth > screenHeight ? 'Landscape' : 'Portrait'),
          ResponsiveSpacing(height: ResponsiveUtils.spacingM),
          ResponsiveButton(
            'Refresh Info',
            onPressed: () => setState(() {}),
            backgroundColor: Colors.grey[600],
            textColor: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: ResponsiveUtils.spacingS),
      child: ResponsiveRow(
        children: [
          ResponsiveText(
            '$label:',
            fontSize: ResponsiveUtils.fontSizeM,
            fontWeight: FontWeight.w600,
          ),
          ResponsiveSpacing(width: ResponsiveUtils.spacingM),
          ResponsiveText(
            value,
            fontSize: ResponsiveUtils.fontSizeM,
            color: Colors.grey[600],
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: ResponsiveText(message),
        backgroundColor: Ec_PRIMARY,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ResponsiveUtils.cardRadius),
        ),
      ),
    );
  }
}
