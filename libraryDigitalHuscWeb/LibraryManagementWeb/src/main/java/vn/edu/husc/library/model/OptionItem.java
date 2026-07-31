package vn.edu.husc.library.model;

public class OptionItem {

    private int id;
    private String name;

    public OptionItem() {
    }

    public OptionItem(int id, String name) {
        this.id = id;
        this.name = name;
    }

    public int getId() {
        return id;
    }

    public String getName() {
        return name;
    }
}