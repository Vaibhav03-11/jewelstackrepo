import 'package:flutter/material.dart';
import '../../domain/inventory_item_model.dart';
import '../../../../core/constants/colors.dart';

class InventoryCard extends StatelessWidget {
  final InventoryItem item;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const InventoryCard({
    Key? key,
    required this.item,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              // Item Image
              _buildItemImage(),
              SizedBox(width: 16),
              
              // Item Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Item Name and Stock Status
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _buildStockIndicator(),
                      ],
                    ),
                    SizedBox(height: 8),
                    
                    // Purity and Weight
                    Text(
                      'Purity: ${item.purity}',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 4),
                    
                    // Weight and Price
                    Row(
                      children: [
                        Text(
                          'Weight: ${item.weight}g',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Spacer(),
                        Text(
                          '₹${item.price.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryGold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    
                    // Stock and Actions
                    Row(
                      children: [
                        Text(
                          'Stock: ${item.stock}',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 14,
                            color: item.isOutOfStock ? AppColors.error : AppColors.textSecondary,
                            fontWeight: item.isOutOfStock ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        Spacer(),
                        _buildActionButtons(),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemImage() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: AppColors.lightBackground,
        image: item.imageUrl != null
            ? DecorationImage(
                image: NetworkImage(item.imageUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: item.imageUrl == null
          ? Icon(
              Icons.inventory_2,
              size: 30,
              color: AppColors.primaryGold,
            )
          : null,
    );
  }

  Widget _buildStockIndicator() {
    Color indicatorColor;
    String statusText;

    if (item.isOutOfStock) {
      indicatorColor = AppColors.error;
      statusText = 'Out of Stock';
    } else if (item.stock < 5) {
      indicatorColor = AppColors.warning;
      statusText = 'Low Stock';
    } else {
      indicatorColor = AppColors.success;
      statusText = 'In Stock';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: indicatorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: indicatorColor.withOpacity(0.3)),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: indicatorColor,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Edit Button
        IconButton(
          icon: Icon(Icons.edit, size: 18),
          onPressed: onEdit,
          color: AppColors.primaryGold,
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(),
        ),
        // Delete Button
        IconButton(
          icon: Icon(Icons.delete, size: 18),
          onPressed: onDelete,
          color: AppColors.error,
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(),
        ),
      ],
    );
  }
}