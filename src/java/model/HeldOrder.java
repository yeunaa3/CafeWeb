package model;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

public class HeldOrder {
    private String holdId;
    private Timestamp createdAt;
    private List<CartItem> items;

    public HeldOrder() {
        this.holdId = UUID.randomUUID().toString();
        this.createdAt = new Timestamp(System.currentTimeMillis());
        this.items = new ArrayList<CartItem>();
    }

    public HeldOrder(List<CartItem> items) {
        this();
        this.items = new ArrayList<CartItem>(items);
    }

    public int getItemCount() {
        int count = 0;
        for (CartItem item : items) count += item.getQuantity();
        return count;
    }

    public double getTotal() {
        double total = 0;
        for (CartItem item : items) total += item.getLineTotal();
        return total;
    }

    public String getHoldId() { return holdId; }
    public void setHoldId(String holdId) { this.holdId = holdId; }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
    public List<CartItem> getItems() { return items; }
    public void setItems(List<CartItem> items) { this.items = items; }
}
