package model;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class CashierOrderView {
    private int orderId;
    private String customerName;
    private String customerPhone;
    private Integer staffId;
    private double totalPrice;
    private double discountAmount;
    private Timestamp orderDate;
    private String status;
    private String orderType;
    private String shippingAddress;
    private String paymentMethod;
    private String note;
    private List<String> items;

    public CashierOrderView() {
        this.items = new ArrayList<String>();
    }

    public void addItem(String item) {
        if (item != null && !item.trim().isEmpty()) {
            items.add(item);
        }
    }

    public String getDisplayStatus() {
        if ("Pending".equalsIgnoreCase(status)) return "Chờ duyệt";
        if ("Processing".equalsIgnoreCase(status)) return "Đã duyệt";
        if ("Paid".equalsIgnoreCase(status)) return "Đã thanh toán";
        if ("Completed".equalsIgnoreCase(status)) return "Hoàn thành";
        if ("Cancelled".equalsIgnoreCase(status)) return "Đã từ chối";
        return status;
    }

    public int getOrderId() { return orderId; }
    public void setOrderId(int orderId) { this.orderId = orderId; }

    public String getCustomerName() { return customerName; }
    public void setCustomerName(String customerName) { this.customerName = customerName; }

    public String getCustomerPhone() { return customerPhone; }
    public void setCustomerPhone(String customerPhone) { this.customerPhone = customerPhone; }

    public Integer getStaffId() { return staffId; }
    public void setStaffId(Integer staffId) { this.staffId = staffId; }

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
