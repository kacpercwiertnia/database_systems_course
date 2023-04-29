package org.example;

import javax.persistence.Entity;
import javax.persistence.PrimaryKeyJoinColumn;

@Entity
@PrimaryKeyJoinColumn(name = "CustomerId")
public class Customer extends Company{
    private double discount;

    public Customer(){
    }

    public Customer(String companyName, String street, String city, String zipCode, double discount){
        super(companyName, street, city, zipCode);
        this.discount = discount;
    }

    public String toString(){
        return this.companyName + " " + Double.toString(this.discount);
    }
}
