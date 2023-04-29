package org.example;

import javax.persistence.*;
import java.util.HashSet;
import java.util.Set;

@Entity
public class Product {
    @Id
    @GeneratedValue(
            strategy = GenerationType.AUTO)
    private int dbID;
    private String productName;
    private int unitsOnStock;
    @ManyToMany(mappedBy = "Products")
    private Set<Invoice> Invoices = new HashSet<>();

    public Product(){
    }

    public Product(String productName, int unitsOnStock){
        this.productName = productName;
        this.unitsOnStock = unitsOnStock;
    }

    public Set<Invoice> getInvoices(){
        return this.Invoices;
    }

    public void addInvoice(Invoice invoice){
        this.Invoices.add(invoice);
    }

    public String toString(){
        return this.productName;
    }

}
