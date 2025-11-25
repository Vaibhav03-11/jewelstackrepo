import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jewelstack/core/utils/image_utils.dart';
import 'package:provider/provider.dart';
import '../../application/inventory_provider.dart';
import '../../domain/inventory_item_model.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/widgets/custom_textfield.dart';

class AddInventoryPage extends StatefulWidget {
  final InventoryItem? item;

  const AddInventoryPage({Key? key, this.item}) : super(key: key);

  @override
  _AddInventoryPageState createState() => _AddInventoryPageState();
}

class _AddInventoryPageState extends State<AddInventoryPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String _selectedCategory = 'Necklace';
  String _selectedPurity = '22K Gold';
  XFile? _selectedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // If editing existing item, populate fields
    if (widget.item != null) {
      _populateFields();
    }
  }

  void _populateFields() {
    final item = widget.item!;
    _nameController.text = item.name;
    _weightController.text = item.weight.toString();
    _stockController.text = item.stock.toString();
    _priceController.text = item.price.toString();
    _descriptionController.text = item.description ?? '';
    _selectedCategory = item.category;
    _selectedPurity = item.purity;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );
      if (image != null) {
        // Validate image before setting
        await ImageUtils.validateImage(image);
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

// Add this method to show loading dialog
  void _showLoadingDialog() {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGold),
          ),
          SizedBox(height: 16),
          Text(
            widget.item == null ? 'Adding Item...' : 'Updating Item...',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 16,
            ),
          ),
        ],
      ),
    ),
  );
}

// Update _saveItem method:
Future<void> _saveItem() async {
  if (!_formKey.currentState!.validate()) return;

  _showLoadingDialog(); // Show loading dialog

  try {
    final inventoryProvider = Provider.of<InventoryProvider>(context, listen: false);
    
    final item = InventoryItem(
      id: widget.item?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      category: _selectedCategory,
      purity: _selectedPurity,
      weight: double.parse(_weightController.text),
      stock: int.parse(_stockController.text),
      price: double.parse(_priceController.text),
      description: _descriptionController.text.trim().isEmpty 
          ? null 
          : _descriptionController.text.trim(),
      imageUrl: widget.item?.imageUrl,
      createdAt: widget.item?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (widget.item == null) {
      await inventoryProvider.addItem(item, _selectedImage);
    } else {
      await inventoryProvider.updateItem(item, _selectedImage);
    }

    Navigator.pop(context); // Close loading dialog
    Navigator.pop(context); // Close the page
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.item == null ? 'Item added successfully' : 'Item updated successfully'
        ),
        backgroundColor: AppColors.success,
      ),
    );
  } catch (e) {
    Navigator.pop(context); // Close loading dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to save item: $e'),
        backgroundColor: AppColors.error,
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          widget.item == null ? 'Add Inventory Item' : 'Edit Inventory Item',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primaryGold,
        foregroundColor: AppColors.textLight,
        elevation: 0,
        actions: [
          if (widget.item != null)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: _deleteItem,
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Image Picker
                _buildImagePicker(),
                SizedBox(height: 24),

                // Item Name
                CustomTextField(
                  label: 'Item Name',
                  hintText: 'Enter item name',
                  controller: _nameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter item name';
                    }
                    return null;
                  }, onChanged: (value) {  }, onTap: () {  },
                ),
                SizedBox(height: 20),

                // Category and Purity
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Category',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.borderColor),
                              borderRadius: BorderRadius.circular(12),
                              color: AppColors.cardBackground,
                            ),
                            child: DropdownButton<String>(
                              value: _selectedCategory,
                              isExpanded: true,
                              underline: SizedBox(),
                              items: InventoryCategories.categories
                                  .map((category) => DropdownMenuItem(
                                        value: category,
                                        child: Text(category),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedCategory = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Purity',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.borderColor),
                              borderRadius: BorderRadius.circular(12),
                              color: AppColors.cardBackground,
                            ),
                            child: DropdownButton<String>(
                              value: _selectedPurity,
                              isExpanded: true,
                              underline: SizedBox(),
                              items: InventoryCategories.purityOptions
                                  .map((purity) => DropdownMenuItem(
                                        value: purity,
                                        child: Text(purity),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedPurity = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // Weight and Stock
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'Weight (grams)',
                        hintText: '0.0',
                        controller: _weightController,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter weight';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter valid weight';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: CustomTextField(
                        label: 'Stock',
                        hintText: '0',
                        controller: _stockController,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter stock';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Please enter valid stock';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // Price
                CustomTextField(
                  label: 'Price (₹)',
                  hintText: '0.00',
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter price';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter valid price';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),

                // Description
                CustomTextField(
                  label: 'Description (Optional)',
                  hintText: 'Enter item description',
                  controller: _descriptionController,
                  keyboardType: TextInputType.multiline,
                ),
                SizedBox(height: 32),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveItem,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGold,
                      foregroundColor: AppColors.textLight,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.textLight,
                            ),
                          )
                        : Text(
                            widget.item == null ? 'Add Item' : 'Update Item',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderColor),
            borderRadius: BorderRadius.circular(12),
            color: AppColors.cardBackground,
          ),
          child: _selectedImage != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    _selectedImage!.path,
                    fit: BoxFit.cover,
                  ),
                )
              : widget.item?.imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        widget.item!.imageUrl!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Icon(
                      Icons.inventory_2,
                      size: 40,
                      color: AppColors.hintColor,
                    ),
        ),
        SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: _pickImage,
          icon: Icon(Icons.camera_alt, size: 18),
          label: Text('Add Image'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.cardBackground,
            foregroundColor: AppColors.textPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: AppColors.borderColor),
            ),
          ),
        ),
      ],
    );
  }

  void _deleteItem() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Item'),
        content: Text('Are you sure you want to delete ${_nameController.text}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isLoading = true);
              try {
                await Provider.of<InventoryProvider>(context, listen: false)
                    .deleteItem(widget.item!.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Item deleted successfully'),
                    backgroundColor: AppColors.success,
                  ),
                );
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to delete item: $e'),
                    backgroundColor: AppColors.error,
                  ),
                );
              } finally {
                if (mounted) {
                  setState(() => _isLoading = false);
                }
              }
            },
            child: Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _stockController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}