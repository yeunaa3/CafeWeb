package model;

import java.sql.Timestamp;

public class PointTransaction {
    private int pointTransactionId;
    private int userId;
    private Integer orderId;
    private Integer voucherId;
    private int pointsChange;
    private int balanceAfter;
    private String transactionType;
    private String description;
    private Timestamp createdAt;

    public PointTransaction() {}

    public int getPointTransactionId() { return pointTransactionId; }
    public void setPointTransactionId(int pointTransactionId) { this.pointTransactionId = pointTransactionId; }
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }
    public Integer getOrderId() { return orderId; }
    public void setOrderId(Integer orderId) { this.orderId = orderId; }
    public Integer getVoucherId() { return voucherId; }
    public void setVoucherId(Integer voucherId) { this.voucherId = voucherId; }
    public int getPointsChange() { return pointsChange; }
    public void setPointsChange(int pointsChange) { this.pointsChange = pointsChange; }
    public int getBalanceAfter() { return balanceAfter; }
    public void setBalanceAfter(int balanceAfter) { this.balanceAfter = balanceAfter; }
    public String getTransactionType() { return transactionType; }
    public void setTransactionType(String transactionType) { this.transactionType = transactionType; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}
