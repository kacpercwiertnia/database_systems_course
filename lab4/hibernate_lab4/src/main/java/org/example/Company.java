package org.example;

import javax.persistence.*;

@Entity
@Inheritance(strategy = InheritanceType.JOINED)
public abstract class Company {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private int id;
    protected String companyName;
    protected String street;
    protected String city;
    protected String zipCode;

    public Company(){

    }

    public Company(String companyName, String street, String city, String zipCode){
        this.companyName = companyName;
        this.street = street;
        this.city = city;
        this.zipCode = zipCode;
    }
}
