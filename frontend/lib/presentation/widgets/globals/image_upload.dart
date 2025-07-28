import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:frontend/src/utils/responsive_breakpoints.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../../src/services/receipt_image_service.dart';

// Responsive wrapper for the image upload functionality
class ResponsiveImageUploadWidget extends StatefulWidget {
  final String? initialImagePath;
  final Function(String?) onImageChanged;
  final String label;
  final BuildContext context;

  const ResponsiveImageUploadWidget({
    super.key,
    this.initialImagePath,
    required this.onImageChanged,
    this.label = 'Receipt Image',
    required this.context,
  });

  @override
  State<ResponsiveImageUploadWidget> createState() => _ResponsiveImageUploadWidgetState();
}

class _ResponsiveImageUploadWidgetState extends State<ResponsiveImageUploadWidget>
    with SingleTickerProviderStateMixin {
  String? _imagePath;
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _imagePath = widget.initialImagePath;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      setState(() {
        _isUploading = true;
        _uploadProgress = 0.0;
      });

      await _updateProgress(0.3);

      final File? imageFile = await DesktopReceiptImageService.pickImageFile();
      if (imageFile == null) {
        setState(() {
          _isUploading = false;
        });
        return;
      }

      await _updateProgress(0.6);

      final bool isValid = await DesktopReceiptImageService.validateImageFile(imageFile);
      if (!isValid) {
        setState(() {
          _isUploading = false;
        });
        _showErrorMessage('Invalid image file. Please select a valid image (max 10MB).');
        return;
      }

      await _updateProgress(0.8);

      final String savedPath = await DesktopReceiptImageService.saveImageToAppDirectory(imageFile);

      if (_imagePath != null && _imagePath != savedPath) {
        await DesktopReceiptImageService.deleteImage(_imagePath!);
      }

      await _updateProgress(1.0);

      setState(() {
        _imagePath = savedPath;
        _isUploading = false;
        _uploadProgress = 0.0;
      });

      widget.onImageChanged(_imagePath);
      _showSuccessMessage('Receipt image uploaded successfully!');
    } catch (e) {
      setState(() {
        _isUploading = false;
        _uploadProgress = 0.0;
      });
      _showErrorMessage('Failed to upload image: ${e.toString()}');
    }
  }

  Future<void> _updateProgress(double progress) async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) {
      setState(() {
        _uploadProgress = progress;
      });
    }
  }

  void _removeImage() async {
    if (_imagePath != null) {
      await DesktopReceiptImageService.deleteImage(_imagePath!);
      setState(() {
        _imagePath = null;
      });
      widget.onImageChanged(null);
      _showInfoMessage('Receipt image removed');
    }
  }

  void _viewImage() {
    if (_imagePath != null) {
      showDialog(
        context: context,
        builder: (context) => ResponsiveImageViewDialog(
          imagePath: _imagePath!,
          context: widget.context,
        ),
      );
    }
  }

  void _openInExternalViewer() async {
    if (_imagePath != null) {
      try {
        await DesktopReceiptImageService.openInExternalViewer(_imagePath!);
      } catch (e) {
        _showErrorMessage('Failed to open image: ${e.toString()}');
      }
    }
  }

  void _showInExplorer() async {
    if (_imagePath != null) {
      try {
        await DesktopReceiptImageService.showInExplorer(_imagePath!);
      } catch (e) {
        _showErrorMessage('Failed to show in explorer: ${e.toString()}');
      }
    }
  }

  void _copyToClipboard() async {
    if (_imagePath != null) {
      try {
        await DesktopReceiptImageService.copyImageToClipboard(_imagePath!);
        _showSuccessMessage('Image copied to clipboard!');
      } catch (e) {
        _showErrorMessage('Failed to copy to clipboard: ${e.toString()}');
      }
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: widget.context.iconSize('small')),
            SizedBox(width: widget.context.smallPadding),
            Text(
              message,
              style: GoogleFonts.inter(
                fontSize: widget.context.bodyFontSize,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(widget.context.borderRadius()),
        ),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: Colors.white, size: widget.context.iconSize('small')),
            SizedBox(width: widget.context.smallPadding),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.inter(
                  fontSize: widget.context.bodyFontSize,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(widget.context.borderRadius()),
        ),
      ),
    );
  }

  void _showInfoMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.info, color: Colors.white, size: widget.context.iconSize('small')),
            SizedBox(width: widget.context.smallPadding),
            Text(
              message,
              style: GoogleFonts.inter(
                fontSize: widget.context.bodyFontSize,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(widget.context.borderRadius()),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(widget.context.smallPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_imagePath != null && !_isUploading) _buildActionButtons(),
          if (_imagePath != null && !_isUploading)
            SizedBox(height: widget.context.smallPadding),
          Expanded(
            child: _isUploading
                ? _buildUploadProgress()
                : _imagePath == null
                ? _buildImagePicker()
                : _buildImagePreview(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final bool isCompact = widget.context.shouldShowCompactLayout;

    if (isCompact) {
      return Container(
        height: ResponsiveBreakpoints.responsive(
          widget.context,
          tablet: 40,
          small: 45,
          medium: 50,
          large: 55,
          ultrawide: 60,
        ),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: 5,
          separatorBuilder: (context, index) => SizedBox(width: widget.context.smallPadding / 2),
          itemBuilder: (context, index) {
            switch (index) {
              case 0:
                return _buildActionChip(Icons.visibility, 'View', Colors.blue, _viewImage);
              case 1:
                return _buildActionChip(Icons.open_in_new, 'Open', Colors.green, _openInExternalViewer);
              case 2:
                return _buildActionChip(Icons.folder_open, 'Explorer', Colors.orange, _showInExplorer);
              case 3:
                return _buildActionChip(Icons.content_copy, 'Copy', Colors.purple, _copyToClipboard);
              case 4:
                return _buildActionChip(Icons.delete, 'Remove', Colors.red, _removeImage);
              default:
                return SizedBox.shrink();
            }
          },
        ),
      );
    } else {
      return Wrap(
        spacing: widget.context.smallPadding / 2,
        runSpacing: widget.context.smallPadding / 2,
        children: [
          _buildActionButton(Icons.visibility, 'View Image', Colors.blue, _viewImage),
          _buildActionButton(Icons.open_in_new, 'Open', Colors.green, _openInExternalViewer),
          _buildActionButton(Icons.folder_open, 'Explorer', Colors.orange, _showInExplorer),
          _buildActionButton(Icons.content_copy, 'Copy', Colors.purple, _copyToClipboard),
          _buildActionButton(Icons.delete, 'Remove', Colors.red, _removeImage),
        ],
      );
    }
  }

  Widget _buildActionChip(IconData icon, String label, Color color, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: ResponsiveBreakpoints.responsive(
          widget.context,
          tablet: 36,
          small: 40,
          medium: 44,
          large: 48,
          ultrawide: 52,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: widget.context.smallPadding,
          vertical: widget.context.smallPadding / 3,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(widget.context.borderRadius('large')),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: widget.context.iconSize('small')),
            SizedBox(width: widget.context.smallPadding / 2),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: ResponsiveBreakpoints.responsive(
                  widget.context,
                  tablet: 10,
                  small: 11,
                  medium: 12,
                  large: 13,
                  ultrawide: 14,
                ),
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String tooltip, Color color, VoidCallback onPressed) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: color),
        iconSize: widget.context.iconSize('medium'),
      ),
    );
  }

  Widget _buildImagePicker() {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTap: _pickImage,
        onTapDown: (_) => _animationController.forward(),
        onTapUp: (_) => _animationController.reverse(),
        onTapCancel: () => _animationController.reverse(),
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _isHovering ? Colors.blue.withOpacity(0.05) : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(widget.context.borderRadius()),
                  border: Border.all(
                    color: _isHovering ? Colors.blue.withOpacity(0.5) : Colors.grey.shade300,
                    width: _isHovering ? 2 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(widget.context.cardPadding),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(_isHovering ? 0.2 : 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.add_photo_alternate_outlined,
                        size: ResponsiveBreakpoints.responsive(
                          widget.context,
                          tablet: 30,
                          small: 35,
                          medium: 40,
                          large: 45,
                          ultrawide: 50,
                        ),
                        color: Colors.blue[600],
                      ),
                    ),
                    SizedBox(height: widget.context.cardPadding),
                    Text(
                      'Click to select receipt image',
                      style: GoogleFonts.inter(
                        fontSize: widget.context.bodyFontSize,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: widget.context.smallPadding),
                    Text(
                      widget.context.shouldShowCompactLayout
                          ? 'JPG, PNG, BMP, GIF (max 10MB)'
                          : 'Supported formats: JPG, PNG, BMP, GIF (max 10MB)',
                      style: GoogleFonts.inter(
                        fontSize: widget.context.captionFontSize,
                        color: Colors.grey[500],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: widget.context.cardPadding),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: widget.context.cardPadding,
                        vertical: widget.context.smallPadding,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(widget.context.borderRadius('large')),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.folder_open,
                            size: widget.context.iconSize('small'),
                            color: Colors.blue[600],
                          ),
                          SizedBox(width: widget.context.smallPadding),
                          Text(
                            'Browse Files',
                            style: GoogleFonts.inter(
                              fontSize: widget.context.captionFontSize,
                              fontWeight: FontWeight.w500,
                              color: Colors.blue[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildUploadProgress() {
    return Container(
      padding: EdgeInsets.all(widget.context.cardPadding),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(widget.context.borderRadius()),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: ResponsiveBreakpoints.responsive(
              widget.context,
              tablet: 50,
              small: 55,
              medium: 60,
              large: 65,
              ultrawide: 70,
            ),
            height: ResponsiveBreakpoints.responsive(
              widget.context,
              tablet: 50,
              small: 55,
              medium: 60,
              large: 65,
              ultrawide: 70,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: _uploadProgress,
                  strokeWidth: ResponsiveBreakpoints.responsive(
                    widget.context,
                    tablet: 4,
                    small: 5,
                    medium: 6,
                    large: 6,
                    ultrawide: 7,
                  ),
                  color: Colors.blue,
                  backgroundColor: Colors.blue.withOpacity(0.2),
                ),
                Text(
                  '${(_uploadProgress * 100).toInt()}%',
                  style: GoogleFonts.inter(
                    fontSize: widget.context.captionFontSize,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: widget.context.cardPadding),
          Text(
            'Processing image file...',
            style: GoogleFonts.inter(
              fontSize: widget.context.bodyFontSize,
              fontWeight: FontWeight.w500,
              color: Colors.blue[700],
            ),
          ),
          SizedBox(height: widget.context.smallPadding),
          Text(
            _getProgressText(),
            style: GoogleFonts.inter(
              fontSize: widget.context.captionFontSize,
              color: Colors.blue[600],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: widget.context.cardPadding),
          LinearProgressIndicator(
            value: _uploadProgress,
            backgroundColor: Colors.blue.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            minHeight: ResponsiveBreakpoints.responsive(
              widget.context,
              tablet: 4,
              small: 5,
              medium: 6,
              large: 6,
              ultrawide: 7,
            ),
          ),
        ],
      ),
    );
  }

  String _getProgressText() {
    if (_uploadProgress < 0.3) return 'Opening file dialog...';
    if (_uploadProgress < 0.6) return 'Validating image file...';
    if (_uploadProgress < 0.8) return 'Saving to application directory...';
    return 'Finalizing...';
  }

  Widget _buildImagePreview() {
    return Container(
      padding: EdgeInsets.all(widget.context.cardPadding),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.05),
        borderRadius: BorderRadius.circular(widget.context.borderRadius()),
        border: Border.all(color: Colors.green.withOpacity(0.2)),
      ),
      child: widget.context.shouldShowCompactLayout
          ? _buildCompactImagePreview()
          : _buildExpandedImagePreview(),
    );
  }

  Widget _buildCompactImagePreview() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: ResponsiveBreakpoints.responsive(
            widget.context,
            tablet: 80,
            small: 90,
            medium: 100,
            large: 110,
            ultrawide: 120,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.context.borderRadius()),
            border: Border.all(color: Colors.green.withOpacity(0.3)),
          ),
          child: _buildImageThumbnail(),
        ),
        SizedBox(height: widget.context.cardPadding),
        _buildFileInfo(),
        SizedBox(height: widget.context.cardPadding),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _pickImage,
            icon: Icon(Icons.edit, size: widget.context.iconSize('small')),
            label: Text(
              'Replace Image',
              style: GoogleFonts.inter(
                fontSize: widget.context.captionFontSize,
                fontWeight: FontWeight.w500,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: widget.context.cardPadding,
                vertical: widget.context.smallPadding,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpandedImagePreview() {
    return Row(
      children: [
        Container(
          width: ResponsiveBreakpoints.responsive(
            widget.context,
            tablet: 80,
            small: 85,
            medium: 90,
            large: 95,
            ultrawide: 100,
          ),
          height: ResponsiveBreakpoints.responsive(
            widget.context,
            tablet: 80,
            small: 85,
            medium: 90,
            large: 95,
            ultrawide: 100,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.context.borderRadius()),
            border: Border.all(color: Colors.green.withOpacity(0.3)),
          ),
          child: _buildImageThumbnail(),
        ),
        SizedBox(width: widget.context.cardPadding),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFileInfo(),
              SizedBox(height: widget.context.cardPadding),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: Icon(Icons.edit, size: widget.context.iconSize('small')),
                label: Text(
                  'Replace',
                  style: GoogleFonts.inter(
                    fontSize: widget.context.captionFontSize,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: widget.context.cardPadding,
                    vertical: widget.context.smallPadding / 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageThumbnail() {
    return FutureBuilder<Uint8List?>(
      future: DesktopReceiptImageService.getImageBytes(_imagePath!),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(widget.context.borderRadius()),
            child: Image.memory(
              snapshot.data!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          );
        }
        return Container(
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(widget.context.borderRadius()),
          ),
          child: Icon(
            Icons.receipt,
            color: Colors.green,
            size: widget.context.iconSize('large'),
          ),
        );
      },
    );
  }

  Widget _buildFileInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Receipt uploaded successfully',
          style: GoogleFonts.inter(
            fontSize: widget.context.bodyFontSize,
            fontWeight: FontWeight.w600,
            color: Colors.green[700],
          ),
        ),
        SizedBox(height: widget.context.smallPadding / 2),
        FutureBuilder<Map<String, dynamic>>(
          future: DesktopReceiptImageService.getFileInfo(_imagePath!),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              final fileInfo = snapshot.data!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'File: ${_truncateFileName(fileInfo['name'] ?? 'Unknown')}',
                    style: GoogleFonts.inter(
                      fontSize: widget.context.captionFontSize,
                      color: Colors.green[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Size: ${DesktopReceiptImageService.formatFileSize(fileInfo['size'] ?? 0)}',
                    style: GoogleFonts.inter(
                      fontSize: widget.context.captionFontSize,
                      color: Colors.green[600],
                    ),
                  ),
                  if (fileInfo['created'] != null) ...[
                    SizedBox(height: 2),
                    Text(
                      'Added: ${_formatDate(fileInfo['created'])}',
                      style: GoogleFonts.inter(
                        fontSize: ResponsiveBreakpoints.responsive(
                          widget.context,
                          tablet: 10,
                          small: 11,
                          medium: 12,
                          large: 13,
                          ultrawide: 14,
                        ),
                        color: Colors.green[500],
                      ),
                    ),
                  ],
                ],
              );
            }
            return Text(
              'Loading file info...',
              style: GoogleFonts.inter(
                fontSize: widget.context.captionFontSize,
                color: Colors.green[600],
              ),
            );
          },
        ),
      ],
    );
  }

  String _truncateFileName(String fileName) {
    if (fileName.length <= 25) return fileName;

    final extension = fileName.contains('.') ? fileName.split('.').last : '';
    final nameWithoutExt = fileName.contains('.')
        ? fileName.substring(0, fileName.lastIndexOf('.'))
        : fileName;

    if (extension.isNotEmpty) {
      final maxNameLength = 25 - extension.length - 4; // -4 for "..." and "."
      if (nameWithoutExt.length > maxNameLength) {
        return '${nameWithoutExt.substring(0, maxNameLength)}...$extension';
      }
    }

    return '${fileName.substring(0, 22)}...';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

// Responsive Image View Dialog
class ResponsiveImageViewDialog extends StatelessWidget {
  final String imagePath;
  final BuildContext context;

  const ResponsiveImageViewDialog({
    super.key,
    required this.imagePath,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(this.context.mainPadding),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: ResponsiveBreakpoints.responsive(
            this.context,
            tablet: 90.w,
            small: 85.w,
            medium: 80.w,
            large: 75.w,
            ultrawide: 70.w,
          ),
          maxHeight: ResponsiveBreakpoints.responsive(
            this.context,
            tablet: 85.h,
            small: 90.h,
            medium: 80.h,
            large: 75.h,
            ultrawide: 70.h,
          ),
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(this.context.borderRadius('large')),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: this.context.shadowBlur('heavy'),
              offset: Offset(0, this.context.cardPadding),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Expanded(child: _buildImageContent()),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(context.borderRadius('large')),
          topRight: Radius.circular(context.borderRadius('large')),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.receipt, color: Colors.blue, size: context.iconSize('medium')),
          SizedBox(width: context.cardPadding),
          Text(
            'Receipt Image Viewer',
            style: GoogleFonts.inter(
              fontSize: context.bodyFontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          if (!context.shouldShowCompactLayout) ...[
            _buildHeaderActions(),
          ] else ...[
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(Icons.close, size: context.iconSize('medium')),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeaderActions() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Tooltip(
          message: 'Open in External Viewer',
          child: IconButton(
            onPressed: () async {
              try {
                await DesktopReceiptImageService.openInExternalViewer(imagePath);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to open: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            icon: Icon(Icons.open_in_new, size: this.context.iconSize('medium')),
          ),
        ),
        Tooltip(
          message: 'Show in Explorer',
          child: IconButton(
            onPressed: () async {
              try {
                await DesktopReceiptImageService.showInExplorer(imagePath);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to show in explorer: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            icon: Icon(Icons.folder_open, size: this.context.iconSize('medium')),
          ),
        ),
        Tooltip(
          message: 'Copy to Clipboard',
          child: IconButton(
            onPressed: () async {
              try {
                await DesktopReceiptImageService.copyImageToClipboard(imagePath);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Image copied to clipboard!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to copy: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            icon: Icon(Icons.content_copy, size: this.context.iconSize('medium')),
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.close, size: this.context.iconSize('medium')),
        ),
      ],
    );
  }

  Widget _buildImageContent() {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      child: FutureBuilder<Uint8List?>(
        future: DesktopReceiptImageService.getImageBytes(imagePath),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    strokeWidth: ResponsiveBreakpoints.responsive(
                      this.context,
                      tablet: 3,
                      small: 4,
                      medium: 4,
                      large: 5,
                      ultrawide: 5,
                    ),
                  ),
                  SizedBox(height: this.context.cardPadding),
                  Text(
                    'Loading image...',
                    style: GoogleFonts.inter(
                      fontSize: this.context.bodyFontSize,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          if (snapshot.hasData && snapshot.data != null) {
            return InteractiveViewer(
              panEnabled: true,
              boundaryMargin: EdgeInsets.all(this.context.cardPadding),
              minScale: 0.1,
              maxScale: 5.0,
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(this.context.borderRadius()),
                  child: Image.memory(
                    snapshot.data!,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            );
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: ResponsiveBreakpoints.responsive(
                    this.context,
                    tablet: 48,
                    small: 52,
                    medium: 56,
                    large: 60,
                    ultrawide: 64,
                  ),
                  color: Colors.grey[400],
                ),
                SizedBox(height: this.context.cardPadding),
                Text(
                  'Failed to load image',
                  style: GoogleFonts.inter(
                    fontSize: this.context.bodyFontSize,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: this.context.cardPadding),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await DesktopReceiptImageService.openInExternalViewer(imagePath);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to open: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: this.context.cardPadding,
                      vertical: this.context.smallPadding,
                    ),
                  ),
                  child: Text(
                    'Open with External Viewer',
                    style: GoogleFonts.inter(
                      fontSize: this.context.captionFontSize,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(context.borderRadius('large')),
          bottomRight: Radius.circular(context.borderRadius('large')),
        ),
      ),
      child: FutureBuilder<Map<String, dynamic>>(
        future: DesktopReceiptImageService.getFileInfo(imagePath),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final fileInfo = snapshot.data!;
            return ResponsiveBreakpoints.responsive(
              this.context,
              tablet: _buildCompactFooter(fileInfo),
              small: _buildCompactFooter(fileInfo),
              medium: _buildExpandedFooter(fileInfo),
              large: _buildExpandedFooter(fileInfo),
              ultrawide: _buildExpandedFooter(fileInfo),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildCompactFooter(Map<String, dynamic> fileInfo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'File: ${fileInfo['name'] ?? 'Unknown'}',
          style: GoogleFonts.inter(
            fontSize: context.captionFontSize,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: context.smallPadding / 2),
        Text(
          'Size: ${DesktopReceiptImageService.formatFileSize(fileInfo['size'] ?? 0)}',
          style: GoogleFonts.inter(
            fontSize: context.captionFontSize,
            color: Colors.grey[600],
          ),
        ),
        if (context.shouldShowCompactLayout) ...[
          SizedBox(height: context.cardPadding),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      await DesktopReceiptImageService.openInExternalViewer(imagePath);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red),
                      );
                    }
                  },
                  icon: Icon(Icons.open_in_new, size: context.iconSize('small')),
                  label: Text('Open', style: GoogleFonts.inter(fontSize: context.captionFontSize)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: context.smallPadding),
                  ),
                ),
              ),
              SizedBox(width: context.smallPadding),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: context.smallPadding),
                  ),
                  child: Text('Close', style: GoogleFonts.inter(fontSize: context.captionFontSize)),
                ),
              ),
            ],
          ),
        ] else ...[
          SizedBox(height: context.cardPadding),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: Text('Close'),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildExpandedFooter(Map<String, dynamic> fileInfo) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'File: ${fileInfo['name'] ?? 'Unknown'}',
                style: GoogleFonts.inter(
                  fontSize: context.captionFontSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Size: ${DesktopReceiptImageService.formatFileSize(fileInfo['size'] ?? 0)} • Modified: ${_formatDate(fileInfo['modified'] ?? DateTime.now())}',
                style: GoogleFonts.inter(
                  fontSize: context.captionFontSize,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          child: Text('Close'),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}