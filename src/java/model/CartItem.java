/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

/**
 *
 * @author Dumpling
 */
public class CartItem {
    private String cartKey;
    private int productId;
    private String productName;
    private String imageUrl;
    private int quantity;
    private String selectedSize;
    private String iceLevel;
    private String sugarLevel;
    private double drinkPrice;
    private List<Topping> toppings;

    public CartItem() {
        this.cartKey = UUID.randomUUID().toString();
        this.toppings = new ArrayList<Topping>();
    }

    public double getToppingTotal() {
        double total = 0;
        if (toppings != null) {
            for (Topping topping : toppings) {
                total += topping.getPrice();
            }
        }
        return total;
    }

    public double getUnitPrice() {
        return drinkPrice + getToppingTotal();
    }

    public double getLineTotal() {
        return getUnitPrice() * quantity;
    }

    public boolean hasSameOptions(CartItem other) {
        if (other == null) return false;
        if (productId != other.productId) return false;
        if (!safeEquals(selectedSize, other.selectedSize)) return false;
        if (!safeEquals(iceLevel, other.iceLevel)) return false;
        if (!safeEquals(sugarLevel, other.sugarLevel)) return false;
        return getToppingSignature().equals(other.getToppingSignature());
    }

    public String getToppingSignature() {
        StringBuilder builder = new StringBuilder();
        if (toppings != null) {
            for (Topping topping : toppings) {
                builder.append(topping.getToppingId()).append("-");
            }
        }
        return builder.toString();
    }

    private boolean safeEquals(String first, String second) {
        if (first == null) return second == null;
        return first.equals(second);
    }

    public String getCartKey() { return cartKey; }
    public void setCartKey(String cartKey) { this.cartKey = cartKey; }

    public int getProductId() { return productId; }
    public void setProductId(int productId) { this.productId = productId; }

    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }

    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }

    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }

    public String getSelectedSize() { return selectedSize; }
    public void setSelectedSize(String selectedSize) { this.selectedSize = selectedSize; }

    public String getIceLevel() { return iceLevel; }
    public void setIceLevel(String iceLevel) { this.iceLevel = iceLevel; }

    public String getSugarLevel() { return sugarLevel; }
    public void setSugarLevel(String sugarLevel) { this.sugarLevel = sugarLevel; }

    public double getDrinkPrice() { return drinkPrice; }
    public void setDrinkPrice(double drinkPrice) { this.drinkPrice = drinkPrice; }

    public List<Topping> getToppings() { return toppings; }
    public void setToppings(List<Topping> toppings) { this.toppings = toppings; }
}
