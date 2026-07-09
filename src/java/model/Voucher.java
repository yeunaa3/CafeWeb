/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

import java.sql.Timestamp;

/**
 *
 * @author Dumpling
 */
public class Voucher {
    private int voucherId;
    private String voucherCode;
    private double discountValue;
    private double minOrderValue;
    private int pointsCost;
    private Timestamp startDate;
    private Timestamp expiryDate;
    private boolean status;
    private Integer ownerUserId;
    private Timestamp usedAt;
    private Timestamp createdAt;

    public Voucher() {}

    public int getVoucherId() { return voucherId; }
    public void setVoucherId(int voucherId) { this.voucherId = voucherId; }

    public String getVoucherCode() { return voucherCode; }
    public void setVoucherCode(String voucherCode) { this.voucherCode = voucherCode; }

    public double getDiscountValue() { return discountValue; }
    public void setDiscountValue(double discountValue) { this.discountValue = discountValue; }

    public double getMinOrderValue() { return minOrderValue; }
    public void setMinOrderValue(double minOrderValue) { this.minOrderValue = minOrderValue; }

    public int getPointsCost() { return pointsCost; }
    public void setPointsCost(int pointsCost) { this.pointsCost = pointsCost; }

    public Timestamp getStartDate() { return startDate; }
    public void setStartDate(Timestamp startDate) { this.startDate = startDate; }

    public Timestamp getExpiryDate() { return expiryDate; }
    public void setExpiryDate(Timestamp expiryDate) { this.expiryDate = expiryDate; }

    public boolean isStatus() { return status; }
    public void setStatus(boolean status) { this.status = status; }

    public Integer getOwnerUserId() { return ownerUserId; }
    public void setOwnerUserId(Integer ownerUserId) { this.ownerUserId = ownerUserId; }

    public Timestamp getUsedAt() { return usedAt; }
    public void setUsedAt(Timestamp usedAt) { this.usedAt = usedAt; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public boolean isExpired() {
        return expiryDate != null && expiryDate.getTime() < System.currentTimeMillis();
    }
}
