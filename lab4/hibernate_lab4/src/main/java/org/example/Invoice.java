package org.example;

import javax.persistence.*;
import java.util.HashSet;
import java.util.Set;

@Entity
public class Invoice {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private int InvoiceID;
    private int InvoiceNumber;
    private int Quantity;
    @ManyToMany(cascade = {CascadeType.PERSIST})
    Set<Product> Products = new HashSet<>();

    public Invoice(){}

    public Invoice(int invoiceNumber, int quantity){
        this.InvoiceNumber = invoiceNumber;
        this.Quantity = quantity;
    }

    public void addProduct(Product product){
        this.Products.add(product);
    }

    public Set<Product> getProducts(){
        return this.Products;
    }
    public String toString(){
        return Integer.toString(this.InvoiceNumber);
    }
}
