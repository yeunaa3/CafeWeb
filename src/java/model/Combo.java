package model;

import java.sql.Timestamp;

public class Combo {
    private int comboId;
    private String comboName;
    private double comboPrice;
    private String imageUrl;
    private String description;
    private Timestamp startDate;
    private Timestamp endDate;
    private boolean status;

    public Combo() {}

    public int getComboId() { return comboId; }
    public void setComboId(int comboId) { this.comboId = comboId; }
    public String getComboName() { return comboName; }
    public void setComboName(String comboName) { this.comboName = comboName; }
    public double getComboPrice() { return comboPrice; }
    public void setComboPrice(double comboPrice) { this.comboPrice = comboPrice; }
    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public Timestamp getStartDate() { return startDate; }
    public void setStartDate(Timestamp startDate) { this.startDate = startDate; }
    public Timestamp getEndDate() { return endDate; }
    public void setEndDate(Timestamp endDate) { this.endDate = endDate; }
    public boolean isStatus() { return status; }
    public void setStatus(boolean status) { this.status = status; }
}
