package model;

import java.sql.Timestamp;

public class ManagerOrderSummary {
    private int orderId;
    private String customerName;
    private Timestamp orderDate;
    private double totalPrice;
    private String status;
    private String orderType;
    private String paymentMethod;
    private String shippingAddress;
    private String shippingPhone;
    private String note;
    private String items;

    public ManagerOrderSummary() {}

    public int getOrderId() { return orderId; }
    public void setOrderId(int orderId) { this.orderId = orderId; }
    public String getCustomerName() { return customerName; }
    public void setCustomerName(String customerName) { this.customerName = customerName; }
    public Timestamp getOrderDate() { return orderDate; }
    public void setOrderDate(Timestamp orderDate) { this.orderDate = orderDate; }
    public double getTotalPrice() { return totalPrice; }
    public void setTotalPrice(double totalPrice) { this.totalPrice = totalPrice; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getOrderType() { return orderType; }
    public void setOrderType(String orderType) { this.orderType = orderType; }
    public String getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }
    public String getShippingAddress() { return shippingAddress; }
    public void setShippingAddress(String shippingAddress) { this.shippingAddress = shippingAddress; }
    public String getShippingPhone() { return shippingPhone; }
    public void setShippingPhone(String shippingPhone) { this.shippingPhone = shippingPhone; }
    public String getNote() { return note; }
    public void setNote(String note) { this.note = note; }
    public String getItems() { return items; }
    public void setItems(String items) { this.items = items; }

    public String getDisplayStatus() {
        if ("Pending".equals(status)) return "Chờ duyệt";
        if ("Approved".equals(status)) return "Đã duyệt";
        if ("Completed".equals(status)) return "Hoàn thành";
        if ("Cancelled".equals(status)) return "Đã hủy";
        return status;
    }
}


