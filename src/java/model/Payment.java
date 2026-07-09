package model;

import java.sql.Timestamp;

public class Payment {
    private int paymentId;
    private int orderId;
    private String paymentMethod;
    private double amount;
    private Double amountReceived;
    private double changeAmount;
    private String transactionCode;
    private String paymentStatus;
    private Timestamp paidAt;
    private Timestamp createdAt;

    public Payment() {}

    public int getPaymentId() { return paymentId; }
    public void setPaymentId(int paymentId) { this.paymentId = paymentId; }
    public int getOrderId() { return orderId; }
    public void setOrderId(int orderId) { this.orderId = orderId; }
    public String getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }
    public double getAmount() { return amount; }
    public void setAmount(double amount) { this.amount = amount; }
    public Double getAmountReceived() { return amountReceived; }
    public void setAmountReceived(Double amountReceived) { this.amountReceived = amountReceived; }
    public double getChangeAmount() { return changeAmount; }
    public void setChangeAmount(double changeAmount) { this.changeAmount = changeAmount; }
    public String getTransactionCode() { return transactionCode; }
    public void setTransactionCode(String transactionCode) { this.transactionCode = transactionCode; }
    public String getPaymentStatus() { return paymentStatus; }
    public void setPaymentStatus(String paymentStatus) { this.paymentStatus = paymentStatus; }
    public Timestamp getPaidAt() { return paidAt; }
    public void setPaidAt(Timestamp paidAt) { this.paidAt = paidAt; }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}
