/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

/**
 *
 * @author Dumpling
 */
public class RedeemOption {
    private int pointsCost;
    private double discountValue;
    private double minOrderValue;
    private int validDays;

    public RedeemOption() {}

    public RedeemOption(int pointsCost, double discountValue, double minOrderValue, int validDays) {
        this.pointsCost = pointsCost;
        this.discountValue = discountValue;
        this.minOrderValue = minOrderValue;
        this.validDays = validDays;
    }

    public int getPointsCost() { return pointsCost; }
    public void setPointsCost(int pointsCost) { this.pointsCost = pointsCost; }

    public double getDiscountValue() { return discountValue; }
    public void setDiscountValue(double discountValue) { this.discountValue = discountValue; }

    public double getMinOrderValue() { return minOrderValue; }
    public void setMinOrderValue(double minOrderValue) { this.minOrderValue = minOrderValue; }

    public int getValidDays() { return validDays; }
    public void setValidDays(int validDays) { this.validDays = validDays; }
}
