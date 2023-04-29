package org.example;

import javax.persistence.*;
import java.util.HashSet;
import java.util.Set;

@Entity
@PrimaryKeyJoinColumn(name = "Supplier")
public class Supplier extends Company{
    private String bankAccountNumber;

    public Supplier(){
    }

    public Supplier(String companyName, String street, String city, String zipCode, String bankAccountNumber){
        super(companyName, street, city, zipCode);
        this.bankAccountNumber = bankAccountNumber;
    }

    public String toString(){
        return this.companyName + " " + this.bankAccountNumber;
    }
}
