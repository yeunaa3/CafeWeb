package model;

import java.sql.Timestamp;

public class OrderStatusHistory {
    private int historyId;
    private int orderId;
    private String oldStatus;
    private String newStatus;
    private Integer changedBy;
    private Timestamp changedAt;
    private String note;

    public OrderStatusHistory() {}

    public int getHistoryId() { return historyId; }
    public void setHistoryId(int historyId) { this.historyId = historyId; }
    public int getOrderId() { return orderId; }
    public void setOrderId(int orderId) { this.orderId = orderId; }
    public String getOldStatus() { return oldStatus; }
    public void setOldStatus(String oldStatus) { this.oldStatus = oldStatus; }
    public String getNewStatus() { return newStatus; }
    public void setNewStatus(String newStatus) { this.newStatus = newStatus; }
    public Integer getChangedBy() { return changedBy; }
    public void setChangedBy(Integer changedBy) { this.changedBy = changedBy; }
    public Timestamp getChangedAt() { return changedAt; }
    public void setChangedAt(Timestamp changedAt) { this.changedAt = changedAt; }
    public String getNote() { return note; }
    public void setNote(String note) { this.note = note; }
}
