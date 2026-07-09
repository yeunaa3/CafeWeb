package model;

public class ComboItem {
    private int comboId;
    private int productId;
    private int quantity;

    public ComboItem() {}

    public int getComboId() { return comboId; }
    public void setComboId(int comboId) { this.comboId = comboId; }
    public int getProductId() { return productId; }
    public void setProductId(int productId) { this.productId = productId; }
    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }
}
