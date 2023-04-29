package org.example;

import javax.persistence.*;
import java.util.HashSet;
import java.util.Set;
@Entity
public class Category {
    @Id
    @GeneratedValue(
            strategy = GenerationType.AUTO)
    private int CategoryID;
    private String Name;
    @OneToMany
    @JoinColumn(name="CATEGORY_FK")
    private Set<Product> Products = new HashSet<>();

    public Category(){
    }

    public Category(String name){
        this.Name = name;
    }

    public void addProduct(Product product){
        this.Products.add(product);
        //product.setCategory(this);
    }

    public Set<Product> getProducts(){
        return Products;
    }

    public String toString(){
        return this.Name;
    }
}
