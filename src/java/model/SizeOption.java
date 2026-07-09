package model;

public class SizeOption {
    private int sizeId;
    private String sizeCode;
    private String sizeName;
    private double priceModifier;
    private boolean status;

    public SizeOption() {}

    public int getSizeId() { return sizeId; }
    public void setSizeId(int sizeId) { this.sizeId = sizeId; }
    public String getSizeCode() { return sizeCode; }
    public void setSizeCode(String sizeCode) { this.sizeCode = sizeCode; }
    public String getSizeName() { return sizeName; }
    public void setSizeName(String sizeName) { this.sizeName = sizeName; }
    public double getPriceModifier() { return priceModifier; }
    public void setPriceModifier(double priceModifier) { this.priceModifier = priceModifier; }
    public boolean isStatus() { return status; }
    public void setStatus(boolean status) { this.status = status; }
}
