/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author Dumpling
 */
public class CustomerOrderSummary {
    private int orderId;
    private double totalPrice;
    private double discountAmount;
    private Timestamp orderDate;
    private String status;
    private String orderType;
    private String shippingAddress;
    private String paymentMethod;
    private String note;
    private List<String> items;

    public CustomerOrderSummary() {
        this.items = new ArrayList<String>();
    }

    public void addItem(String item) {
        if (item != null && !item.trim().isEmpty()) {
            items.add(item);
        }
    }

    public String getDisplayStatus() {
        if ("Pending".equalsIgnoreCase(status)) return "Chờ duyệt";
        if ("Processing".equalsIgnoreCase(status)) return "Đang xử lý";
        if ("Paid".equalsIgnoreCase(status)) return "Đã thanh toán";
        if ("Completed".equalsIgnoreCase(status)) return "Hoàn thành";
        if ("Cancelled".equalsIgnoreCase(status)) return "Đã hủy";
        return status;
    }

    public int getOrderId() { return orderId; }
    public void setOrderId(int orderId) { this.orderId = orderId; }

    public double getTotalPrice() { return totalPrice; }
    public void setTotalPrice(double totalPrice) { this.totalPrice = totalPrice; }

    public double getDiscountAmount() { return discountAmount; }
    public void setDiscountAmount(double discountAmount) { this.discountAmount = discountAmount; }

    public Timestamp getOrderDate() { return orderDate; }
    public void setOrderDate(Timestamp orderDate) { this.orderDate = orderDate; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getOrderType() { return orderType; }
    public void setOrderType(String orderType) { this.orderType = orderType; }

    public String getShippingAddress() { return shippingAddress; }
    public void setShippingAddress(String shippingAddress) { this.shippingAddress = shippingAddress; }

    public String getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }

    public String getNote() { return note; }
    public void setNote(String note) { this.note = note; }

    public List<String> getItems() { return items; }
    public void setItems(List<String> items) { this.items = items; }
}
